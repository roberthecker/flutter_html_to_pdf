import UIKit

class PDFCreator {
    
    /**
     Creates a PDF using the given print formatter and saves it to the user's document directory.
     - returns: The generated PDF path.
     */
    class func create(printFormatter: UIPrintFormatter, isPortrait: Bool) -> URL {
        
        // assign the print formatter to the print page renderer
        let renderer = UIPrintPageRenderer()
        
        renderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        let widthA4 = isPortrait ? 595.2 : 841.8;
        let heightA4 = isPortrait ? 841.8 : 595.2;
        
        // create some sensible margins
        let pageMargins = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 15)

        // calculate the printable rect from the above two
        let printableRect = CGRect(x: pageMargins.left, y: pageMargins.top, width: CGFloat(widthA4) - pageMargins.left - pageMargins.right, height: CGFloat(heightA4) - pageMargins.top - pageMargins.bottom)
        // assign paperRect and printableRect values
        let page = CGRect(x: 0, y: 0, width: widthA4, height: heightA4) // A4, 72 dpi
        renderer.setValue(page, forKey: "paperRect")
        renderer.setValue(printableRect, forKey: "printableRect")
        
        // create pdf context and draw each page
        let pdfData = NSMutableData()
        UIGraphicsBeginPDFContextToData(pdfData, page, nil)
        
        for i in 0..<renderer.numberOfPages {
            UIGraphicsBeginPDFPage()
            renderer.drawPage(at: i, in: UIGraphicsGetPDFContextBounds())
        }
        
        UIGraphicsEndPDFContext();
        
        guard nil != (try? pdfData.write(to: createdFileURL, options: .atomic))
            else { fatalError("Error writing PDF data to file.") }
        
        return createdFileURL;
    }
    
    /**
     Creates temporary PDF document URL
     */
    private class var createdFileURL: URL {
        
        guard let directory = try? FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
            else { fatalError("Error getting user's document directory.") }
        
        let url = directory.appendingPathComponent("generatedPdfFile").appendingPathExtension("pdf")
        return url
    }
    
    /**
     Search for matches in provided text
     */
    private class func matches(for regex: String, in text: String) -> [String] {
        do {
            let regex = try NSRegularExpression(pattern: regex)
            let nsString = text as NSString
            let results = regex.matches(in: text, range: NSRange(location: 0, length: nsString.length))
            return results.map { nsString.substring(with: $0.range)}
        } catch let error {
            print("invalid regex: \(error.localizedDescription)")
            return []
        }
    }
}
