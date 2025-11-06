from locust import HttpUser, task, between
import random

class OrderServiceUser(HttpUser):
    wait_time = between(1, 2)  # Wait 1-2 seconds between tasks
    
    @task
    def create_order(self):
        self.client.post("/orders", json={
            "product_id": str(random.randint(100, 999)),
            "quantity": random.randint(1, 5)
        })