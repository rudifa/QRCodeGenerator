#  QRCodeGenerator

Initially based on code from Appcoda article [Building a QR Code Generator with Core Image Filters](https://www.appcoda.com/qr-code-generator-tutorial).

Extracted and refined QRCode generation and manipulation into `struct QRCodeGenerator`.
Added controls to ViewController to manipulate text entry, size, redundancy, url encode or not, mode (.blackOnWhite, .whiteOnClear, .clearOnWhite).


## `struct QRCodeGenerator`

Generates an UIImage from the input text string.

The API consists of an initializer and input and output properties.

Initializer with default property values:
```
    init(qrText: String = "",
correctionLevel: CorrectionLevel = .corrPct25,
    imageSidePt: CGFloat = 0.0,
     urlEncoded: Bool = false,
           mode: Mode = .blackOnWhite)
```


Input properties:
```
var qrText: String                      // text to be encoded
var correctionLevel: CorrectionLevel    // correction/reundancy level
var imageSidePt: CGFloat                // side size of the quadratic generated image
var urlEncoded: Bool                    // url-encodes qrText if true else uses qrText
var mode: Mode                          // output mode

CorrectionLevel:    corrPct7, corrPct15, corrPct25, corrPct30
Mode:               blackOnWhite, whiteOnClear, clearOnWhite

```

Output property:
```
var uiImage: UIImage?   // the generated image
```

Create an instance with default property values:
```
var generator = QRCodeGenerator()
```
Modify its properties:
```
generator.qrText = "Hello"
generator.correctionLevel = .corrPct7
generator.imageSidePt = 100.0
generator.urlEncoded = true
generator.mode = .clearOnWhite
```
Create an instance with modified properties:
```
let generator2 = QRCodeGenerator(qrText: "Bye",
     correctionLevel: .corrPct30,
     imageSidePt: 200.0,
     urlEncoded: true,
     mode: .clearOnWhite)
```

Get the generated QR code image:
```
let image: UIImage = generator.uiImage()!
```
