# Lab 11 notes

## Part 1: Setup and first request

**Question: In product.json, find one field that is a number, one that is a list of strings, one that is a nested object and one that is a list of objects.**

The `price` field is a number: its value is `9.99`. The `tags` field is a list of strings containing `"beauty"` and `"mascara"`. For a nested object, there is `dimensions`, which contains the product's width, height, and depth. The `reviews` field is a list of objects, since each review has its own rating, comment, date, and reviewer details.

**Question: Change the address to /products/0. What status code and body come back?**

The request returned status code `404` with this body:

```json
{"message":"Product with id '0' not found"}
```

This means there is no product with ID `0`.
