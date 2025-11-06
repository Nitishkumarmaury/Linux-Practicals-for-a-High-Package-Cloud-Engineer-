from fastapi import FastAPI, HTTPException
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.requests import RequestsInstrumentor
from prometheus_client import Counter, Histogram, start_http_server
import httpx
import logging
import time
import random

# Initialize FastAPI
app = FastAPI()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("order-service")

# Initialize metrics
ORDER_COUNT = Counter(
    'orders_total', 
    'Total number of orders processed',
    ['status']
)
ORDER_LATENCY = Histogram(
    'order_processing_seconds',
    'Time spent processing orders',
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0]
)

# Initialize tracing
tracer = trace.get_tracer(__name__)

@app.post("/orders")
async def create_order():
    with tracer.start_as_current_span("create_order") as span:
        try:
            start_time = time.time()
            
            # Process payment
            async with httpx.AsyncClient() as client:
                payment_response = await client.post(
                    "http://payment-service:8081/process",
                    json={"amount": 100}
                )
                if payment_response.status_code != 200:
                    raise HTTPException(status_code=500, detail="Payment failed")
                
                span.set_attribute("payment_id", payment_response.json()["payment_id"])
            
            # Check inventory
            async with httpx.AsyncClient() as client:
                inventory_response = await client.post(
                    "http://inventory-service:8082/check",
                    json={"product_id": "123"}
                )
                if inventory_response.status_code != 200:
                    raise HTTPException(status_code=500, detail="Inventory check failed")
            
            # Simulate some processing
            processing_time = random.uniform(0.1, 0.5)
            time.sleep(processing_time)
            
            # Record metrics
            ORDER_COUNT.labels(status="success").inc()
            ORDER_LATENCY.observe(time.time() - start_time)
            
            logger.info(
                "Order processed successfully",
                extra={
                    "processing_time": processing_time,
                    "payment_id": payment_response.json()["payment_id"]
                }
            )
            
            return {"status": "success", "order_id": random.randint(1000, 9999)}
            
        except Exception as e:
            ORDER_COUNT.labels(status="error").inc()
            logger.error(f"Order processing failed: {str(e)}")
            raise HTTPException(status_code=500, detail=str(e))

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Instrument FastAPI
FastAPIInstrumentor.instrument_app(app)
RequestsInstrumentor().instrument()

# Start metrics server
start_http_server(8000)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8080)