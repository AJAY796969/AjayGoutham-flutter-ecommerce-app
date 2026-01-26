class AddressModel {
  final String fullName;
  final String phoneNumber;
  final String fullAddress;
  final String city;
  final String state;
  final String pincode;

  AddressModel({
    required this.fullName,
    required this.phoneNumber,
    required this.fullAddress,
    required this.city,
    required this.state,
    required this.pincode,
  });

  Map<String, dynamic> toMap() {
    return {
      "fullName": fullName,
      "phoneNumber": phoneNumber,
      "fullAddress": fullAddress,
      "city": city,
      "state": state,
      "pincode": pincode,
    };
  }

  factory AddressModel.fromMap(Map<String, dynamic> map) {
    return AddressModel(
      fullName: map["fullName"] ?? "",
      phoneNumber: map["phoneNumber"] ?? "",
      fullAddress: map["fullAddress"] ?? "",
      city: map["city"] ?? "",
      state: map["state"] ?? "",
      pincode: map["pincode"] ?? "",
    );
  }
}