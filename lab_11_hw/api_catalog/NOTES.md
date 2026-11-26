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

## Part 2: Models from JSON

**Question: What exactly happens if you write `json['price'] as double` and the server sends `10`? Is the error found at compile time or at run time?**

JSON decoding turns `10` into an `int`. Using `as double` does not convert it, so the cast fails at runtime with a type error. The compiler cannot catch this because the value coming from the map is dynamic. Using `(json['price'] as num).toDouble()` works for both `10` and `9.99`.

**Question: Why is it better to test `fromJson` with a saved file than with a live request?**

A saved file gives the test the same input every time, and it works without an internet connection. If the test fails, we can focus on the parsing code instead of wondering whether the server is down or its data has changed.

**Question: What happens when `brand` and `tags` are missing?**

A missing `brand` becomes `null`, since not every product has a brand. I chose to make missing `tags` an empty list. That way, the product still loads and there are simply no tags to display.
