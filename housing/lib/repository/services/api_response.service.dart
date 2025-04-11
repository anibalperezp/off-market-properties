class APIResponse<T> {
  T? data;
  bool error;
  String? errorMessage;
  bool requiredRefreshToken;

  APIResponse(
      {this.data,
      this.errorMessage,
      this.error = false,
      this.requiredRefreshToken = false});
}
