class ConatctList {
  int id;
  String name;
  String phone;
  // String email;
 String middlename;
  ConatctList(this.id, this.name,this.phone,this.middlename);
 
  Map<String, dynamic> toMap() {
    var map = <String, dynamic>{
      'id': id,
      'name': name,
      'phone': phone,
      // 'email': email,
      'middlename':middlename
    };
    return map;
  }
 
  ConatctList.fromMap(Map<String, dynamic> map) {
    id = map['id'];
    name = map['name'];
    phone= map['phone'];
    //  email= map['email'];
     middlename=map['middlename'];
  }
}