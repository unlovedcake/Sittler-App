class BookModel {
  String? id;

  String? serviceNeed;
  String? dateToBook;
  String? startTime;
  String? endTime;
  String? clientAddress;
  String? appointmentType;
  String? appointmentStatus;
  Map? userModel;
  Map? userStaff;

  BookModel(
      {this.id,
      this.serviceNeed,
      this.dateToBook,
      this.startTime,
      this.endTime,
      this.clientAddress,
      this.appointmentType,
      this.appointmentStatus,
      this.userModel,
      this.userStaff});

  // receiving data from server
  factory BookModel.fromMap(map) {
    return BookModel(
      id: map['id'],
      serviceNeed: map['serviceNeed'],
      dateToBook: map['dateToBook'],
      startTime: map['startTime'],
      endTime: map['endTime'],
      clientAddress: map['clientAddress'],
      appointmentType: map['appointmentType'],
      appointmentStatus: map['appointmentStatus'],
      userModel: map['userModel'],
      userStaff: map['userStaff'],
    );
  }

  // sending data to our server
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'serviceNeed': serviceNeed,
      'dateToBook': dateToBook,
      'startTime': startTime,
      'endTime': endTime,
      'clientAddress': clientAddress,
      'appointmentType': appointmentType,
      'appointmentStatus': appointmentStatus,
      'userModel': userModel,
      'userStaff': userStaff,
    };
  }
}
