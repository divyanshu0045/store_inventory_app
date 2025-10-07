from fastapi import FastAPI, HTTPException
from pydantic import BaseModel, Field
from typing import List, Optional, Dict
import uuid

app = FastAPI()

# --- In-Memory Database ---
# A simple dictionary to act as a mock database.
db: Dict[str, List] = {
    "products": [],
    "suppliers": [],
}

# --- Pydantic Models ---
# These models define the structure of our data and are used for validation.

class Supplier(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    contact_name: Optional[str] = None
    email: Optional[str] = None
    phone: Optional[str] = None

class Product(BaseModel):
    id: str = Field(default_factory=lambda: str(uuid.uuid4()))
    name: str
    sku: str
    description: Optional[str] = None
    category: Optional[str] = None
    supplier_id: Optional[str] = None
    barcode: Optional[str] = None
    stock_quantity: int
    location: Optional[str] = None
    minimum_stock_threshold: Optional[int] = None
    cost: Optional[float] = None
    selling_price: Optional[float] = None

# --- API Endpoints ---

@app.get("/")
def read_root():
    return {"message": "Inventory Management API is running."}

# --- Product Endpoints ---

@app.get("/products", response_model=List[Product])
def get_all_products():
    """
    Retrieve all products from the database.
    """
    return db["products"]

@app.post("/products", response_model=Product, status_code=201)
def create_product(product: Product):
    """
    Create a new product.
    """
    db["products"].append(product)
    return product

@app.get("/products/{product_id}", response_model=Product)
def get_product_by_id(product_id: str):
    """
    Retrieve a single product by its ID.
    """
    for product in db["products"]:
        if product.id == product_id:
            return product
    raise HTTPException(status_code=404, detail="Product not found")

@app.put("/products/{product_id}", response_model=Product)
def update_product(product_id: str, updated_product: Product):
    """
    Update an existing product.
    """
    for i, product in enumerate(db["products"]):
        if product.id == product_id:
            db["products"][i] = updated_product
            return updated_product
    raise HTTPException(status_code=404, detail="Product not found")

@app.delete("/products/{product_id}", status_code=204)
def delete_product(product_id: str):
    """
    Delete a product.
    """
    for i, product in enumerate(db["products"]):
        if product.id == product_id:
            db["products"].pop(i)
            return
    raise HTTPException(status_code=404, detail="Product not found")

# --- Supplier Endpoints ---

@app.get("/suppliers", response_model=List[Supplier])
def get_all_suppliers():
    """
    Retrieve all suppliers from the database.
    """
    return db["suppliers"]

@app.post("/suppliers", response_model=Supplier, status_code=201)
def create_supplier(supplier: Supplier):
    """
    Create a new supplier.
    """
    db["suppliers"].append(supplier)
    return supplier

@app.get("/suppliers/{supplier_id}", response_model=Supplier)
def get_supplier_by_id(supplier_id: str):
    """
    Retrieve a single supplier by its ID.
    """
    for supplier in db["suppliers"]:
        if supplier.id == supplier_id:
            return supplier
    raise HTTPException(status_code=404, detail="Supplier not found")

@app.put("/suppliers/{supplier_id}", response_model=Supplier)
def update_supplier(supplier_id: str, updated_supplier: Supplier):
    """
    Update an existing supplier.
    """
    for i, supplier in enumerate(db["suppliers"]):
        if supplier.id == supplier_id:
            db["suppliers"][i] = updated_supplier
            return updated_supplier
    raise HTTPException(status_code=404, detail="Supplier not found")

@app.delete("/suppliers/{supplier_id}", status_code=204)
def delete_supplier(supplier_id: str):
    """
    Delete a supplier.
    """
    for i, supplier in enumerate(db["suppliers"]):
        if supplier.id == supplier_id:
            db["suppliers"].pop(i)
            return
    raise HTTPException(status_code=404, detail="Supplier not found")