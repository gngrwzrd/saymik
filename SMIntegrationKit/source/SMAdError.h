
enum _SMAdError {
	_SMAdErrorOk                         = 0,
	_SMAdErrorNetworkError               = 1,
	_SMAdErrorConfigNotSet               = 2,
	_SMAdErrorAdNotAvailable             = 3,
	_SMAdErrorLocalFileNotFound          = 4,
	_SMAdErrorInvalidView                = 5,
	_SMAdErrorInternalError              = 6,
	_SMAdErrorCantSendMail               = 7,
	_SMAdErrorCantSendSMS                = 8,
	_SMAdErrorInvalidFCID                = 9,
};
typedef enum _SMAdError _SMAdError;
