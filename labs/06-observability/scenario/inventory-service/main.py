from fastapi import FastAPI
from opentelemetry import trace
from opentelemetry.instrumentation.fastapi import FastAPIInstrumentor
from opentelemetry.instrumentation.psycopg2 import Psycopg2Instrumentor
from prometheus_client import Counter, Gauge, start_http_server
import psycopg2
import logging
import os

app = FastAPI()

# Configure logging
logging.basicConfig(
    level=logging.INFO,
    format='%(asctime)s - %(name)s - %(levelname)s - %(message)s'
)
logger = logging.getLogger("inventory-service")

# Initialize metrics
INVENTORY_CHECKS = Counter(
    'inventory_checks_total',
    'Total number of inventory checks',
    ['status']
)
INVENTORY_LEVEL = Gauge(
    'inventory_level',
    'Current inventory level',
    ['product_id']
)

# Initialize tracing
tracer = trace.get_tracer(__name__)

# Database connection
def get_db_connection():
    return psycopg2.connect(
        host=os.environ.get("DB_HOST", "postgres"),
        port=os.environ.get("DB_PORT", 5432),
        database="inventory",
        user="postgres",
        password="secret"
    )

@app.post("/check")
async def check_inventory():
    with tracer.start_as_current_span("check_inventory") as span:
        try:
            conn = get_db_connection()
            cur = conn.cursor()
            
            # Simulate inventory check
            product_id = "123"
            cur.execute(
                "SELECT quantity FROM inventory WHERE product_id = %s",
                (product_id,)
            )
            result = cur.fetchone()
            
            if result and result[0] > 0:
                INVENTORY_CHECKS.labels(status="available").inc()
                INVENTORY_LEVEL.labels(product_id=product_id).set(result[0])
                
                logger.info(
                    "Inventory check successful",
                    extra={
                        "product_id": product_id,
                        "quantity": result[0]
                    }
                )
                
                return {"status": "available", "quantity": result[0]}
            else:
                INVENTORY_CHECKS.labels(status="out_of_stock").inc()
                logger.warning(
                    "Product out of stock",
                    extra={"product_id": product_id}
                )
                return {"status": "out_of_stock", "quantity": 0}
                
        except Exception as e:
            INVENTORY_CHECKS.labels(status="error").inc()
            logger.error(f"Inventory check failed: {str(e)}")
            raise
        finally:
            if 'cur' in locals():
                cur.close()
            if 'conn' in locals():
                conn.close()

@app.get("/health")
async def health_check():
    try:
        conn = get_db_connection()
        conn.close()
        return {"status": "healthy"}
    except Exception:
        logger.error("Health check failed - database connection error")
        return {"status": "unhealthy"}

# Instrument FastAPI and Psycopg2
FastAPIInstrumentor.instrument_app(app)
Psycopg2Instrumentor().instrument()

# Start metrics server
start_http_server(8002)

if __name__ == "__main__":
    import uvicorn
    uvicorn.run(app, host="0.0.0.0", port=8082)