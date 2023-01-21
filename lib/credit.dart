class Person {
  int id;
  String amount;
  String type;
   String description;
  Person({this.id,this.description, this.amount, this.type});

  factory Person.fromMap(Map<String, dynamic> json) => new Person(
        id: json["id"],
        amount: json["amount"],
        type: json["type"],
        description: json["description"],
      );

  Map<String, dynamic> toMap() => {
        "id": id,
        "amount": amount,
        "type": type,
        "description":description
      }; 
}