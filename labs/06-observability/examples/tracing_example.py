# Tracing Example with OpenTelemetry
from opentelemetry import trace
from opentelemetry.trace import Status, StatusCode
from opentelemetry.sdk.trace import TracerProvider
from opentelemetry.sdk.trace.export import BatchSpanProcessor
from opentelemetry.exporter.jaeger.thrift import JaegerExporter
import asyncio
import random

# Setup tracer
trace.set_tracer_provider(TracerProvider())
tracer = trace.get_tracer(__name__)

# Configure Jaeger exporter
jaeger_exporter = JaegerExporter(
    agent_host_name="localhost",
    agent_port=6831,
)
span_processor = BatchSpanProcessor(jaeger_exporter)
trace.get_tracer_provider().add_span_processor(span_processor)

async def process_order(order_id: str):
    with tracer.start_as_current_span("process_order") as span:
        span.set_attribute("order_id", order_id)
        
        # Validate order
        with tracer.start_span("validate_order") as validate_span:
            await asyncio.sleep(random.random())
            validate_span.set_status(Status(StatusCode.OK))
        
        # Process payment
        with tracer.start_span("process_payment") as payment_span:
            try:
                await asyncio.sleep(random.random())
                if random.random() < 0.1:
                    raise Exception("Payment failed")
                payment_span.set_status(Status(StatusCode.OK))
            except Exception as e:
                payment_span.set_status(Status(StatusCode.ERROR, str(e)))
                raise
        
        # Update inventory
        with tracer.start_span("update_inventory") as inventory_span:
            await asyncio.sleep(random.random())
            inventory_span.set_status(Status(StatusCode.OK))

async def main():
    while True:
        order_id = f"order_{random.randint(1000, 9999)}"
        try:
            await process_order(order_id)
        except Exception as e:
            print(f"Error processing order {order_id}: {e}")
        await asyncio.sleep(1)

if __name__ == "__main__":
    asyncio.run(main())