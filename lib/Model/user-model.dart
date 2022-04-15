class UserModel {
  String? uid;
  String? fullName;
  String? email;
  String? address;
  String? contactNumber;
  String? age;
  String? gender;
  String? token;
  String? imageUrl = "";

  UserModel(
      {this.uid,
      this.fullName,
      this.email,
      this.address,
      this.contactNumber,
      this.age,
      this.gender,
      this.token,
      this.imageUrl});

  // receiving data from server
  factory UserModel.fromMap(map) {
    return UserModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      address: map['address'],
      contactNumber: map['contactNumber'],
      age: map['age'],
      gender: map['gender'],
      token: map['token'],
      imageUrl: map['imageUrl'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'uid': uid,
      'fullName': fullName,
      'email': email,
      'address': address,
      'contactNumber': contactNumber,
      'age': age,
      'gender': gender,
      'token': token,
      'imageUrl': imageUrl,
    };
  }
}
