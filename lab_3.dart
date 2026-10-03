// 5 Comments & Documentation

// 1
/*
class BankAccount {
  double balance;

  BankAccount(double initialDeposit) : balance = initialDeposit {
    if (initialDeposit < 0) {
      throw ArgumentError('Deposit cannot be negative');
    }
  }
}
*/

// 2
/*
void main() {
  int a = 10;
  int b = 5;

  // Add two numbers
  int sum = a + b;

  /*
    Multiply the sum by 2
    and print the result
  */
  int result = sum * 2;

  print(result);
}
*/

// 3
/*
/// A utility class for validating data.
class Validator {
  /// Checks if [age] is valid.
  ///
  /// Returns true if [age] is 18 or more.
  /// Throws an [ArgumentError] if [age] is negative.
  bool validateAge(int age) {
    if (age < 0) {
      throw ArgumentError('Age cannot be negative');
    }

    return age >= 18;
  }
}
*/

// 4
/*
/// Calculates a final price.
///
/// **Rules:**
/// - Price must be positive.
/// - Discount is between 0 and 1.
///
/// Example:
/// ```dart
/// calculatePrice(100, 0.2);
/// ```
double calculatePrice(double price, double discount) {
  return price * (1 - discount);
}
*/

// 5
/*
class Animal {
  void makeSound() {
    print('Animal sound');
  }
}

class Dog extends Animal {
  /// Old method kept for compatibility.
  @Deprecated('Use makeSound instead')
  void bark() {
    print('Woof');
  }

  /// Overrides the parent method.
  @override
  void makeSound() {
    print('Woof');
  }
}
*/


// 6 Classes & Constructors

// 1
/*
class Point {
  final double x;
  final double y;

  const Point(this.x, this.y);

  Point.origin()
      : x = 0,
        y = 0;

  factory Point.fromJson(Map<String, double> json) {
    return Point(
      json['x'] ?? 0,
      json['y'] ?? 0,
    );
  }
}
*/

// 2
/*
class Person {
  String name;
  int age;

  Person(this.name, this.age);
}

void main() {
  Person person = Person('Nurlan', 20);
  print('${person.name} ${person.age}');
}
*/

// 3
/*
class Student {
  final int age;

  Student(int age)
      : assert(age >= 0 && age <= 120),
        age = age;
}

void main() {
  Student student = Student(20);
  print(student.age);
}
*/

// 4
/*
class AppSettings {
  AppSettings._();

  static final AppSettings _instance = AppSettings._();

  factory AppSettings() {
    return _instance;
  }
}

void main() {
  AppSettings a = AppSettings();
  AppSettings b = AppSettings();

  print(identical(a, b));
}
*/

// 5
/*
class BankAccount {
  double _balance = 0;

  double get balance => _balance;

  set balance(double value) {
    if (value >= 0) {
      _balance = value;
    }
  }
}

void main() {
  BankAccount account = BankAccount();
  account.balance = 500;

  print(account.balance);
}
*/


// 7 Enums

// 1
/*
enum Planet {
  mercury(mass: 3.3e23),
  venus(mass: 4.87e24),
  earth(mass: 5.97e24);

  final double mass;

  const Planet({required this.mass});

  bool get isHabitable => this == Planet.earth;
}
*/

// 2
/*
enum Day {
  monday,
  tuesday,
  wednesday,
  thursday,
  friday,
  saturday,
  sunday
}

void main() {
  for (Day day in Day.values) {
    print(day);
  }
}
*/

// 3
/*
enum Status {
  active,
  inactive,
  pending
}

String displayStatus(Status status) {
  return switch (status) {
    Status.active => 'Active',
    Status.inactive => 'Inactive',
    Status.pending => 'Pending',
  };
}

void main() {
  print(displayStatus(Status.active));
}
*/

// 4
/*
abstract class Describable {
  String description();
}

enum Role implements Describable {
  admin,
  user,
  guest;

  @override
  String description() {
    return switch (this) {
      Role.admin => 'Administrator',
      Role.user => 'Regular User',
      Role.guest => 'Guest User',
    };
  }
}

void main() {
  print(Role.admin.description());
}
*/

// 5
/*
enum Color {
  red,
  green,
  blue
}

void main() {
  String input = 'green';

  try {
    Color color = Color.values.byName(input);
    print(color);
  } catch (e) {
    print('Invalid color');
  }
}
*/


// 8 Inheritance

// 1
/*
class Vehicle {
  final String brand;

  Vehicle(this.brand);

  void start() {
    print('$brand starting...');
  }
}

class ElectricCar extends Vehicle {
  final int batteryCapacity;

  ElectricCar(String brand, this.batteryCapacity) : super(brand);

  @override
  void start() {
    super.start();
    print('Battery level: $batteryCapacity kWh');
  }
}
*/

// 2
/*
class Animal {
  void makeSound() {
    print('Animal sound');
  }
}

class Dog extends Animal {
  @override
  void makeSound() {
    print('Woof');
  }
}

void main() {
  Dog dog = Dog();
  dog.makeSound();
}
*/

// 3
/*
class Vehicle {
  final String brand;

  Vehicle(this.brand);
}

class ElectricCar extends Vehicle {
  ElectricCar(super.brand);
}

void main() {
  ElectricCar car = ElectricCar('Tesla');
  print(car.brand);
}
*/

// 4
/*
class Shape {
  void info() {
    print('Shape');
  }
}

class Polygon extends Shape {
  void sides() {
    print('Polygon has sides');
  }
}

class Triangle extends Polygon {
  void type() {
    print('Triangle has 3 sides');
  }
}

void main() {
  Triangle triangle = Triangle();

  triangle.info();
  triangle.sides();
  triangle.type();
}
*/

// 5
/*
abstract class Animal {
  void eat() {
    print('Eating');
  }

  void makeSound();
}

class Cat extends Animal {
  @override
  void makeSound() {
    print('Meow');
  }
}

void main() {
  Cat cat = Cat();

  cat.eat();
  cat.makeSound();
}
*/


// 9 Mixins & Interfaces

// 1
/*
abstract class Printable {
  void printData();
}

mixin TimestampLogger on Printable {
  void logWithTime() {
    print(DateTime.now());
    printData();
  }
}

class Report implements Printable {
  @override
  void printData() {
    print('Q3 Financial Summary');
  }
}
*/

// 2
/*
interface class DBConnector {
  void connect() {
    print('Connecting');
  }
}

class MySQLConnector implements DBConnector {
  @override
  void connect() {
    print('Connected to MySQL');
  }
}

void main() {
  MySQLConnector connector = MySQLConnector();
  connector.connect();
}
*/

// 3
/*
mixin Flyable {
  void fly() {
    print('Flying');
  }
}

class Bird with Flyable {}

void main() {
  Bird bird = Bird();
  bird.fly();
}
*/

// 4
/*
mixin Walker {
  void walk() {
    print('Walking');
  }
}

mixin Swimmer {
  void swim() {
    print('Swimming');
  }
}

mixin Flyable {
  void fly() {
    print('Flying');
  }
}

class Duck with Walker, Swimmer, Flyable {}

void main() {
  Duck duck = Duck();

  duck.walk();
  duck.swim();
  duck.fly();
}
*/

// 5
/*
class Animal {}

mixin Runner on Animal {
  void run() {
    print('Running');
  }
}

class Dog extends Animal with Runner {}

void main() {
  Dog dog = Dog();
  dog.run();
}
*/


// 10 Polymorphism

// 1
/*
abstract class PaymentProcessor {
  void process(double amount);
}

class CreditCardProcessor implements PaymentProcessor {
  @override
  void process(double amount) {
    print('Paid \$$amount via Credit Card');
  }
}

class CryptoProcessor implements PaymentProcessor {
  @override
  void process(double amount) {
    print('Paid \$$amount via Crypto Wallet');
  }
}

void checkout(PaymentProcessor processor, double amount) {
  processor.process(amount);
}
*/

// 2
/*
abstract class Shape {
  double area();
}

class Circle extends Shape {
  final double radius;

  Circle(this.radius);

  @override
  double area() {
    return 3.14 * radius * radius;
  }
}

class Rectangle extends Shape {
  final double width;
  final double height;

  Rectangle(this.width, this.height);

  @override
  double area() {
    return width * height;
  }
}

void main() {
  List<Shape> shapes = [
    Circle(5),
    Rectangle(4, 6),
  ];

  for (Shape shape in shapes) {
    print(shape.area());
  }
}
*/

// 3
/*
void main() {
  Object value = 'Hello';

  if (value is String) {
    print(value.length);
  }

  Object number = 10;

  int n = number as int;

  print(n);
}
*/

// 4
/*
class Repository<T> {
  final List<T> items = [];

  void add(T item) {
    items.add(item);
  }

  List<T> getAll() {
    return items;
  }
}

void main() {
  Repository<String> repository = Repository<String>();

  repository.add('Apple');
  repository.add('Banana');

  print(repository.getAll());
}
*/

// 5
/*
sealed class Result {}

class Success extends Result {
  final String data;

  Success(this.data);
}

class Failure extends Result {
  final String message;

  Failure(this.message);
}

void printResult(Result result) {
  switch (result) {
    case Success():
      print(result.data);

    case Failure():
      print(result.message);
  }
}
*/


// 11 Async Operations

// 1
/*
Future<String> fetchUser() async {
  await Future.delayed(const Duration(seconds: 1));

  return 'User #1024';
}

Stream<int> countStream(int max) async* {
  for (int i = 1; i <= max; i++) {
    await Future.delayed(
      const Duration(milliseconds: 200),
    );

    yield i;
  }
}
*/

// 2
/*
Future<String> findUser() async {
  await Future.delayed(
    const Duration(seconds: 2),
  );

  return 'User found';
}

void main() async {
  String result = await findUser();

  print(result);
}
*/

// 3
/*
Future<String> task1() async {
  await Future.delayed(
    const Duration(seconds: 1),
  );

  return 'Task 1 done';
}

Future<String> task2() async {
  await Future.delayed(
    const Duration(seconds: 1),
  );

  return 'Task 2 done';
}

Future<String> task3() async {
  await Future.delayed(
    const Duration(seconds: 1),
  );

  return 'Task 3 done';
}

void main() async {
  List<String> results = await Future.wait([
    task1(),
    task2(),
    task3(),
  ]);

  print(results);
}
*/

// 4
/*
import 'dart:async';

void main() {
  int count = 0;

  late StreamSubscription<int> subscription;

  subscription = Stream.periodic(
    const Duration(seconds: 1),
    (value) => value,
  ).listen((value) {
    print(value);

    count++;

    if (count == 5) {
      subscription.cancel();
    }
  });
}
*/

// 5
/*
Stream<int> numbers() async* {
  yield* Stream.fromIterable([
    1,
    1,
    2,
    3,
    3,
    4,
    5,
    6
  ]);
}

void main() async {
  await for (
    int value in numbers()
        .map((n) => n * 2)
        .where((n) => n > 4)
        .distinct()
  ) {
    print(value);
  }
}
*/


// 12 Exceptions & Error Handling

// 1
/*
class InsufficientFundsException implements Exception {
  final double required;

  InsufficientFundsException(this.required);

  @override
  String toString() {
    return 'InsufficientFundsException: Missing \$$required';
  }
}

void withdraw(double amount, double balance) {
  if (amount > balance) {
    throw InsufficientFundsException(
      amount - balance,
    );
  }
}

void main() {
  try {
    withdraw(150, 100);
  } on InsufficientFundsException catch (e) {
    print('Caught custom exception: $e');
  } finally {
    print('Transaction complete.');
  }
}
*/

// 2
/*
double divide(double a, double b) {
  if (b == 0) {
    throw UnsupportedError(
      'Cannot divide by zero',
    );
  }

  return a / b;
}

void main() {
  try {
    print(divide(10, 0));
  } on UnsupportedError catch (e) {
    print(e);
  }
}
*/

// 3
/*
void validateName(String? name) {
  if (name == null || name.isEmpty) {
    throw ArgumentError(
      'Name cannot be empty or null',
    );
  }

  print(name);
}

void main() {
  validateName('');
}
*/

// 4
/*
void main() {
  try {
    int number = int.parse('abc');

    print(number);
  } on FormatException {
    print('Format error');
  } on ArgumentError {
    print('Argument error');
  } catch (e) {
    print('Other error: $e');
  }
}
*/

// 5
/*
void main() {
  try {
    int.parse('hello');
  } catch (e, stackTrace) {
    print(e);
    print(stackTrace);
  }
}
*/
