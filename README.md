#  QRCodeGenerator

Initially based on code from Appcoda article [Building a QR Code Generator with Core Image Filters](https://www.appcoda.com/qr-code-generator-tutorial).

Extracted and refined QRCode generation and manipulation into `struct QRCodeGenerator`.
Added controls to ViewController to manipulate text entry, size, redundancy, url encode or not, mode (.blackOnWhite, .whiteOnClear, .clearOnWhite).


## `struct QRCodeGenerator`

Generates an UIImage from the input text string.

The API consists of an initializer and input and output properties.

Initializer with default property values:
```
        init(qrText: String = "hello folks",
customUrlIdentifier: String = "textreader",
    correctionLevel: CorrectionLevel = .corrPct15,
        imageSidePt: CGFloat = 250.0,
          customUrl: Bool = false,
               mode: Mode = .blackOnWhite,
    foregroundColor: CIColor = CIColor(red: 0.206, green: 0.599, blue: 0.860)

```


Input properties:
```
var qrText: String                      // text to be encoded
var customUrlIdentifier: String         // identifier, like "textreader" in "textreader://hello"
var correctionLevel: CorrectionLevel    // correction/reundancy level
var imageSidePt: CGFloat                // side size of the quadratic generated image
var customUrl: Bool                     // false: uses qrText as is, true: creates a custom URL like "textreader://hello%20folks"
var mode: Mode                          // output mode
var foregroundColor: CIColor            // color of the QRCode image

CorrectionLevel:    corrPct7, corrPct15, corrPct25, corrPct30

Mode:               blackOnClear, blackOnColored, blackOnWhite,
                    clearOnBlack, clearOnColored, clearOnWhite,
                    coloredOnBlack, coloredOnClear, coloredOnWhite,
                    whiteOnBlack, whiteOnClear, whiteOnColored

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
customUrlIdentifier: String = "lipreader"
generator.correctionLevel = .corrPct7
generator.imageSidePt = 100.0
generator.customUrl = true
generator.mode = .clearOnWhite
generator.foregroundColor = CIColor(red: 0.99, green: 0.99, blue: 0.0)
```
Create an instance with modified properties:
```
let generator2 = QRCodeGenerator(qrText: "Bye",
     correctionLevel: .corrPct30,
     imageSidePt: 200.0,
     mode: .clearOnWhite)
```

Get the generated QR code image:
```
let image: UIImage = generator.uiImage()!
```

## class ViewController

Provides a test-and-demo UI for various foreground and background colors, QRCode image size and modes,
QRCode redundancy (7%-30%), urlEncoded or plain, and export to photos or to printer.
