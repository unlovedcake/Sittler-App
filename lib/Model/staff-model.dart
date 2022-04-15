class StaffModel {
  String? uid;
  String? fullName;
  String? email;
  String? address;
  String? contactNumber;
  String? gender;
  String? token;

  String? imageUrl = "";
  Map? position;
  double? distance;

  StaffModel(
      {this.uid,
      this.fullName,
      this.email,
      this.address,
      this.contactNumber,
      this.gender,
      this.token,
      this.imageUrl,
      this.position,
      this.distance});

  // receiving data from server
  factory StaffModel.fromMap(map) {
    return StaffModel(
      uid: map['uid'],
      fullName: map['fullName'],
      email: map['email'],
      address: map['address'],
      contactNumber: map['contactNumber'],
      gender: map['gender'],
      token: map['token'],
      imageUrl: map['imageUrl'],
      position: map['position'],
      distance: map['distance'],
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
      'gender': gender,
      'token': token,
      'imageUrl': imageUrl,
      'position': position,
      'distance': distance,
    };
  }
}
