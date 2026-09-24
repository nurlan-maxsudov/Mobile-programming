// Main Function

// void main(List<String> arguments) {
//   print('Hello, Dart World!');

//   if (arguments.isNotEmpty) {
//     print(arguments);
//   }
// }

// void main() {
//   print("Nurlan Maxsudov");
//   print("240442");
//   print("Software Engineering");
// }

// void main(List<String> arguments) {
//   print("Number of arguments: ${arguments.length}");
// }

// void main(List<String> arguments) {
//   if (arguments.isEmpty) {
//     print("Please provide numbers.");
//     return;
//   }

//   double sum = 0;

//   for (String argument in arguments) {
//     double number = double.parse(argument);
//     sum += number;
//   }

//   double average = sum / arguments.length;
//   print("Average: $average");
// }


// Variables & Data Types

// void main() {
//   var mutableName = 'Alice';
//   final String birthCity = 'Tashkent';
//   const double pi = 3.14159;
//   late String description;

//   description = 'Initialized later';

//   print(mutableName);
//   print(birthCity);
//   print(pi);
//   print(description);
// }

// void main() {
//   int age = 19;
//   double gpa = 3.5;
//   String country = 'Uzbekistan';
//   bool isStudent = true;

//   print(age);
//   print(gpa);
//   print(country);
//   print(isStudent);
// }

// void main() {
//   final currentTime = DateTime.now();
//   const university = "New Uzbekistan University";

//   print(currentTime);
//   print(university);
// }

// void main() {
//   String? nickname;
//   String name = "Nurlan";

//   print(nickname ?? "No nickname");
//   print(name);
// }


// Control Flow

// void main() {
//   int score = 85;

//   String grade = switch (score) {
//     >= 90 => 'A',
//     >= 80 => 'B',
//     >= 70 => 'C',
//     _ => 'F',
//   };

//   print(grade);
// }

// void main() {
//   int number = -5;

//   if (number > 0) {
//     print("Positive");
//   } else if (number < 0) {
//     print("Negative");
//   } else {
//     print("Zero");
//   }
// }

// void main() {
//   int number = 5;
//   int factorial = 1;

//   for (int i = 1; i <= number; i++) {
//     factorial *= i;
//   }

//   print(factorial);
// }

// void main() {
//   int guess = 1;
//   int target = 5;

//   while (guess != target) {
//     print("Guess: $guess");
//     guess++;
//   }

//   print("Found the number: $target");
// }


// Functions / Methods

// double calculateTotal(
//   double price, {
//   double discount = 0,
//   double tax = 0.08,
// }) {
//   double discountedPrice = price * (1 - discount);
//   return discountedPrice * (1 + tax);
// }

// void main() {
//   print(calculateTotal(100, discount: 0.10));
// }

// bool isEven(int number) => number % 2 == 0;

// void main() {
//   print(isEven(4));
//   print(isEven(5));
// }

// void greet(String name, [String prefix = "Hello", String suffix = "!"]) {
//   print("$prefix $name$suffix");
// }

// void main() {
//   greet("Nurlan");
//   greet("Nurlan", "Hi");
// }

// List<int> transformNumbers(
//   List<int> numbers,
//   int Function(int) transformer,
// ) {
//   List<int> result = [];

//   for (int number in numbers) {
//     result.add(transformer(number));
//   }

//   return result;
// }

// void main() {
//   List<int> numbers = [1, 2, 3];

//   List<int> doubled = transformNumbers(
//     numbers,
//     (number) => number * 2,
//   );

//   print(doubled);
// }


// Comments & Documentation

// /// Represents a bank account.
// class BankAccount {
//   /// Current account balance.
//   double balance;

//   /// Creates an account.
//   BankAccount(double initialDeposit) : balance = initialDeposit {
//     if (initialDeposit < 0) {
//       throw ArgumentError("Deposit cannot be negative");
//     }
//   }
// }

// void main() {
//   BankAccount account = BankAccount(100);
//   print(account.balance);
// }

// void main() {
//   // Price of one product
//   double price = 10;

//   /*
//      Total price calculation
//   */
//   int quantity = 3;

//   double total = price * quantity;
//   print(total);
// }

// /// Utility class for checking values.
// class Validator {
//   /// Checks if age is 18 or above.
//   bool isAdult(int age) {
//     return age >= 18;
//   }
// }

// void main() {
//   Validator validator = Validator();
//   print(validator.isAdult(20));
// }

// /// Student information.
// ///
// /// **Information**
// /// - Name
// /// - Age
// ///
// /// Example:
// /// ```dart
// /// Student("Nurlan", 19);
// /// ```
// class Student {
//   String name;
//   int age;

//   Student(this.name, this.age);
// }


// Classes & Constructors

// class Point {
//   final double x;
//   final double y;

//   const Point(this.x, this.y);

//   Point.origin()
//       : x = 0,
//         y = 0;

//   factory Point.fromJson(Map<String, double> json) {
//     return Point(
//       json['x'] ?? 0,
//       json['y'] ?? 0,
//     );
//   }
// }

// void main() {
//   Point point = Point(5, 10);

//   print(point.x);
//   print(point.y);
// }

// class Person {
//   String name;
//   int age;

//   Person(this.name, this.age);
// }

// void main() {
//   Person person = Person("Nurlan", 19);

//   print(person.name);
//   print(person.age);
// }

// class Student {
//   String name;
//   int age;

//   Student(this.name, int givenAge)
//       : age = givenAge < 0 ? 0 : givenAge;
// }

// void main() {
//   Student student = Student("Nurlan", 19);
//   print(student.age);
// }

// class Database {
//   static final Database instance = Database._private();

//   Database._private();

//   factory Database() {
//     return instance;
//   }
// }

// void main() {
//   Database first = Database();
//   Database second = Database();

//   print(identical(first, second));
// }


// Enums

// enum Planet {
//   earth(5.97),
//   mars(0.64);

//   final double mass;

//   const Planet(this.mass);

//   bool get isEarth => this == Planet.earth;
// }

// void main() {
//   print(Planet.earth.mass);
//   print(Planet.earth.isEarth);
// }

// enum Day {
//   monday,
//   tuesday,
//   wednesday,
//   thursday,
//   friday,
//   saturday,
//   sunday,
// }

// void main() {
//   for (Day day in Day.values) {
//     print(day);
//   }
// }

// enum Status {
//   loading,
//   success,
//   error,
// }

// String getText(Status status) {
//   return switch (status) {
//     Status.loading => "Loading...",
//     Status.success => "Success!",
//     Status.error => "Error!",
//   };
// }

// void main() {
//   print(getText(Status.success));
// }

// abstract class Printable {
//   String getText();
// }

// enum Direction implements Printable {
//   north,
//   south,
//   east,
//   west;

//   @override
//   String getText() {
//     return name;
//   }
// }

// void main() {
//   print(Direction.north.getText());
// }


// Inheritance

// class Vehicle {
//   String brand;

//   Vehicle(this.brand);

//   void start() {
//     print("$brand is starting");
//   }
// }

// class ElectricCar extends Vehicle {
//   int battery;

//   ElectricCar(String brand, this.battery) : super(brand);

//   @override
//   void start() {
//     super.start();
//     print("Battery: $battery");
//   }
// }

// void main() {
//   ElectricCar car = ElectricCar("Tesla", 100);
//   car.start();
// }

// class Animal {
//   void makeSound() {
//     print("Animal sound");
//   }
// }

// class Dog extends Animal {
//   @override
//   void makeSound() {
//     print("Woof");
//   }
// }

// void main() {
//   Dog dog = Dog();
//   dog.makeSound();
// }

// class Vehicle {
//   String brand;

//   Vehicle(this.brand);
// }

// class ElectricCar extends Vehicle {
//   ElectricCar(super.brand);
// }

// void main() {
//   ElectricCar car = ElectricCar("Tesla");
//   print(car.brand);
// }

// class Shape {
//   void showShape() {
//     print("Shape");
//   }
// }

// class Polygon extends Shape {
//   void showPolygon() {
//     print("Polygon");
//   }
// }

// class Triangle extends Polygon {
//   void showTriangle() {
//     print("Triangle");
//   }
// }

// void main() {
//   Triangle triangle = Triangle();

//   triangle.showShape();
//   triangle.showPolygon();
//   triangle.showTriangle();
// }


// Mixins & Interfaces

// abstract class Printable {
//   void printData();
// }

// mixin TimestampLogger {
//   void showTime() {
//     print(DateTime.now());
//   }
// }

// class Report with TimestampLogger implements Printable {
//   @override
//   void printData() {
//     print("Report data");
//   }
// }

// void main() {
//   Report report = Report();

//   report.printData();
//   report.showTime();
// }

// abstract class DBConnector {
//   void connect();
// }

// class MySQLConnector implements DBConnector {
//   @override
//   void connect() {
//     print("Connected to MySQL");
//   }
// }

// void main() {
//   MySQLConnector database = MySQLConnector();
//   database.connect();
// }

// mixin Flyable {
//   void fly() {
//     print("Flying");
//   }
// }

// class Bird with Flyable {}

// void main() {
//   Bird bird = Bird();
//   bird.fly();
// }

// mixin Walker {
//   void walk() {
//     print("Walking");
//   }
// }

// mixin Swimmer {
//   void swim() {
//     print("Swimming");
//   }
// }

// mixin Flyable {
//   void fly() {
//     print("Flying");
//   }
// }

// class Duck with Walker, Swimmer, Flyable {}

// void main() {
//   Duck duck = Duck();

//   duck.walk();
//   duck.swim();
//   duck.fly();
// }


// Polymorphism

// abstract class PaymentProcessor {
//   void process(double amount);
// }

// class CreditCardProcessor implements PaymentProcessor {
//   @override
//   void process(double amount) {
//     print("Paid $amount using card");
//   }
// }

// void checkout(PaymentProcessor processor, double amount) {
//   processor.process(amount);
// }

// void main() {
//   CreditCardProcessor card = CreditCardProcessor();
//   checkout(card, 100);
// }

// abstract class Shape {
//   double area();
// }

// class Circle implements Shape {
//   double radius;

//   Circle(this.radius);

//   @override
//   double area() {
//     return 3.14 * radius * radius;
//   }
// }

// class Rectangle implements Shape {
//   double width;
//   double height;

//   Rectangle(this.width, this.height);

//   @override
//   double area() {
//     return width * height;
//   }
// }

// void main() {
//   List<Shape> shapes = [
//     Circle(2),
//     Rectangle(4, 5),
//   ];

//   for (Shape shape in shapes) {
//     print(shape.area());
//   }
// }

// class Animal {}

// class Dog extends Animal {
//   void bark() {
//     print("Woof");
//   }
// }

// void main() {
//   Animal animal = Dog();

//   if (animal is Dog) {
//     animal.bark();
//   }

//   Dog dog = animal as Dog;
//   dog.bark();
// }

// class Repository<T> {
//   List<T> items = [];

//   void add(T item) {
//     items.add(item);
//   }

//   void show() {
//     print(items);
//   }
// }

// void main() {
//   Repository<String> names = Repository<String>();

//   names.add("Nurlan");
//   names.add("Ali");

//   names.show();
// }


// Async Operations

// Future<String> fetchUser() async {
//   await Future.delayed(Duration(seconds: 1));
//   return "Nurlan";
// }

// Stream<int> countNumbers() async* {
//   for (int i = 1; i <= 3; i++) {
//     await Future.delayed(Duration(seconds: 1));
//     yield i;
//   }
// }

// void main() async {
//   print(await fetchUser());

//   await for (int number in countNumbers()) {
//     print(number);
//   }
// }

// Future<String> findUser() async {
//   await Future.delayed(Duration(seconds: 2));
//   return "User found";
// }

// void main() async {
//   String result = await findUser();
//   print(result);
// }

// Future<String> taskOne() async {
//   await Future.delayed(Duration(seconds: 1));
//   return "Task 1";
// }

// Future<String> taskTwo() async {
//   await Future.delayed(Duration(seconds: 1));
//   return "Task 2";
// }

// Future<String> taskThree() async {
//   await Future.delayed(Duration(seconds: 1));
//   return "Task 3";
// }

// void main() async {
//   List<String> results = await Future.wait([
//     taskOne(),
//     taskTwo(),
//     taskThree(),
//   ]);

//   print(results);
// }

// import 'dart:async';

// void main() {
//   int count = 0;

//   late StreamSubscription<int> subscription;

//   Stream<int> stream = Stream.periodic(
//     Duration(seconds: 1),
//     (number) => number,
//   );

//   subscription = stream.listen((number) {
//     print(number);

//     count++;

//     if (count == 5) {
//       subscription.cancel();
//     }
//   });
// }


// Exceptions & Error Handling

// class InsufficientFundsException implements Exception {
//   double missingAmount;

//   InsufficientFundsException(this.missingAmount);

//   @override
//   String toString() {
//     return "Missing $missingAmount";
//   }
// }

// void withdraw(double amount, double balance) {
//   if (amount > balance) {
//     throw InsufficientFundsException(amount - balance);
//   }

//   print("Money withdrawn");
// }

// void main() {
//   try {
//     withdraw(150, 100);
//   } on InsufficientFundsException catch (error) {
//     print(error);
//   } finally {
//     print("Transaction finished");
//   }
// }

// double divide(double a, double b) {
//   if (b == 0) {
//     throw UnsupportedError("Cannot divide by zero");
//   }

//   return a / b;
// }

// void main() {
//   try {
//     print(divide(10, 0));
//   } on UnsupportedError catch (error) {
//     print(error);
//   }
// }

// void checkName(String? name) {
//   if (name == null || name.isEmpty) {
//     throw ArgumentError("Name cannot be empty");
//   }

//   print(name);
// }

// void main() {
//   try {
//     checkName("");
//   } catch (error) {
//     print(error);
//   }
// }

// void checkNumber(int number) {
//   if (number < 0) {
//     throw ArgumentError("Number cannot be negative");
//   }

//   if (number == 0) {
//     throw UnsupportedError("Zero is not supported");
//   }

//   print(number);
// }

// void main() {
//   try {
//     checkNumber(-5);
//   } on ArgumentError catch (error) {
//     print("Argument error: $error");
//   } on UnsupportedError catch (error) {
//     print("Unsupported error: $error");
//   } catch (error) {
//     print("Other error: $error");
//   }
// }