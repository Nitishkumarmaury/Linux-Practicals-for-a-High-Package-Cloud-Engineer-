from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from prometheus_client import Counter, Histogram, start_http_server
import time
import random
import logging

app = FastAPI()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("payment-service")

# Initialize metrics
PAYMENT_COUNT = Counter(
    'payments_total',
    'Total number of payments processed',
    ['status']
)
PAYMENT_LATENCY = Histogram(
    'payment_processing_seconds',
    'Time spent processing payments',
    buckets=[0.1, 0.5, 1.0, 2.0, 5.0]
)

# Initialize tracing
tracer = trace.get_tracer(__name__)

@app.post("/process")
async def process_payment():
    with tracer.start_as_current_span("process_payment") as span:
        start_time = time.time()
        
        try:
            # Simulate processing delay
            if random.random() < 0.3:  # 30% chance of high latency
                time.sleep(random.uniform(2.0, 4.0))
                logger.warning("Payment processing experiencing high latency")
            else:
                time.sleep(random.uniform(0.1, 0.3))
            
            # Simulate occasional failures
            if random.random() < 0.1:  # 10% chance of failure
                logger.error("Payment processing failed")
                PAYMENT_COUNT.labels(status="error").inc()
                raise Exception("Payment gateway error")
            
            payment_id = random.randint(10000, 99999)
            span.set_attribute("payment_id", payment_id)
            
            # Record success metrics
            PAYMENT_COUNT.labels(status="success").inc()
            PAYMENT_LATENCY.observe(time.time() - start_time)
            
            logger.info(
                "Payment processed successfully",
                extra={"payment_id": payment_id}
            )
            
            return {"status": "success", "payment_id": payment_id}
            
        except Exception as e:
            PAYMENT_COUNT.labels(status="error").inc()
            PAYMENT_LATENCY.observe(time.time() - start_time)
            logger.error(f"Payment processing error: {str(e)}")
            raise

@app.get("/health")
async def health_check():
    return {"status": "healthy"}

# Instrument FastAPI
FastAPIInstrumentor.instrument_app(app)

# Start metrics server
start_http_server(8001)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8081)