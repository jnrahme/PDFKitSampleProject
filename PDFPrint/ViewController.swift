import UIKit
import PDFKit
import MobileCoreServices
import UniformTypeIdentifiers

class ViewController: UIViewController {
    // Create a PDFView for displaying PDF documents
    private let pdfView: PDFView = {
        let view = PDFView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    // Create a StackView for holding buttons
    private let buttonStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.backgroundColor = .gray
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        stackView.spacing = 8 // Adjust button spacing as needed
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    // Create a button for printing
    private lazy var printButton: UIButton = {
        let button = createButton(title: "", iconName: "printer.fill")
        return button
    }()
    
    // Create a button for saving
    private lazy var saveButton: UIButton = {
        let button = createButton(title: "", iconName: "square.and.arrow.down.fill")
        return button
    }()
    
    // Create a button for viewing files
    private lazy var viewFilesButton: UIButton = {
        let button = createButton(title: "", iconName: "folder.fill")
        return button
    }()
    
    // Create a button for toggling annotation mode
    private lazy var annotationToggleButton: UIButton = {
        let button = createButton(title: "", iconName: "pencil")
        return button
    }()
    
    // Flag to track if annotation mode is on
    private var isAnnotationModeOn = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupSubviews()
        setupConstraints()
        setupGestureRecognizers()
    }
    
    // Set up the view hierarchy and initial PDF document
    private func setupSubviews() {
        view.backgroundColor = .white
        
        // Load a PDF document (Replace 'dummy.pdf' with your desired PDF file name)
        if let pdfURL = Bundle.main.url(forResource: "dummy", withExtension: "pdf") {
            pdfView.document = PDFDocument(url: pdfURL)
            pdfView.autoScales = true
        }
        
        // Add button stack view and PDF view to the main view
        view.addSubview(buttonStackView)
        view.addSubview(pdfView)
        
        // Add buttons to the stack view
        buttonStackView.addArrangedSubview(printButton)
        buttonStackView.addArrangedSubview(saveButton)
        buttonStackView.addArrangedSubview(viewFilesButton)
        buttonStackView.addArrangedSubview(annotationToggleButton)
    }
    
    // Set up layout constraints for the button stack view and PDF view
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            buttonStackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            buttonStackView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            buttonStackView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            buttonStackView.heightAnchor.constraint(equalToConstant: 50),
            
            pdfView.topAnchor.constraint(equalTo: buttonStackView.bottomAnchor),
            pdfView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            pdfView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            pdfView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
        ])
    }
    
    // Set up gesture recognizers for button actions and annotation handling
    private func setupGestureRecognizers() {
        // Add actions to the buttons
        printButton.addTarget(self, action: #selector(printButtonTapped), for: .touchUpInside)
        saveButton.addTarget(self, action: #selector(saveButtonTapped), for: .touchUpInside)
        viewFilesButton.addTarget(self, action: #selector(viewFilesButtonTapped), for: .touchUpInside)
        annotationToggleButton.addTarget(self, action: #selector(annotationToggleButtonTapped), for: .touchUpInside)

        // Add a double tap gesture gesture recognizer to enable annotation editing
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        pdfView.addGestureRecognizer(doubleTapGesture)
    }

    // Function to create a button with a title and icon
    private func createButton(title: String, iconName: String) -> UIButton {
        let button = UIButton()
        button.backgroundColor = .systemBackground
        button.layer.cornerRadius = 8
        button.setTitleColor(.label, for: .normal)
        button.setTitle(title, for: .normal)
        
        let imageView = UIImageView()
        imageView.image = UIImage(systemName: iconName)
        imageView.translatesAutoresizingMaskIntoConstraints = false

        button.addSubview(imageView)

        // Center the icon both vertically and horizontally within the button
        NSLayoutConstraint.activate([
            imageView.centerXAnchor.constraint(equalTo: button.centerXAnchor),
            imageView.centerYAnchor.constraint(equalTo: button.centerYAnchor),
            imageView.widthAnchor.constraint(equalTo: button.widthAnchor, multiplier: 0.6),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor),
        ])

        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }
    
    // Handle the "Print" button tap
    @objc private func printButtonTapped() {
        // Implementation for printing a PDF document
        let printController = UIPrintInteractionController.shared
        let printInfo = UIPrintInfo(dictionary: nil)
        printInfo.outputType = .general
        printInfo.jobName = "My PDF Print Job"
        printController.printInfo = printInfo
        printController.printingItem = pdfView.document?.dataRepresentation()
        let printBarButtonItem = UIBarButtonItem(customView: printButton)
        printController.present(from: printBarButtonItem, animated: true) { (controller, completed, error) in
            if completed {
                print("Printing completed successfully.")
            } else if let error = error {
                print("Printing error: \(error.localizedDescription)")
            } else {
                print("Printing was canceled.")
            }
        }
    }
    
    // Handle the "Save" button tap
    @objc private func saveButtonTapped() {
        // Implementation for saving a PDF document
        if let pdfData = pdfView.document?.dataRepresentation() {
            let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
            let pdfsDirectory = documentsDirectory.appendingPathComponent("PDFs")
            do {
                try FileManager.default.createDirectory(at: pdfsDirectory, withIntermediateDirectories: true, attributes: nil)
                let pdfFileURL = pdfsDirectory.appendingPathComponent("myPDF.pdf")
                try pdfData.write(to: pdfFileURL)
                print("PDF saved to: \(pdfFileURL.path)")
            } catch {
                print("Error saving PDF: \(error.localizedDescription)")
            }
        }
    }
    
    // Handle the "View" button tap
    @objc private func viewFilesButtonTapped() {
        // Implementation for viewing saved PDF files
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        let pdfsDirectory = documentsDirectory.appendingPathComponent("PDFs")
        let pdf: UTType = .pdf
        let fileBrowser = UIDocumentPickerViewController(forOpeningContentTypes: [pdf])
        fileBrowser.directoryURL = pdfsDirectory
        fileBrowser.delegate = self
        present(fileBrowser, animated: true, completion: nil)
    }
    
    // Handle the "Annotation" toggle button tap
    @objc private func annotationToggleButtonTapped() {
        // Implementation for toggling annotation mode
        isAnnotationModeOn.toggle()
        if isAnnotationModeOn {
            annotationToggleButton.setTitle("Stop", for: .normal)
            enableAnnotationMode()
        } else {
            annotationToggleButton.setTitle("Add", for: .normal)
            disableAnnotationMode()
        }
    }
    
    // Function to enable annotation mode
    private func enableAnnotationMode() {
        // Implementation for enabling annotation mode
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        pdfView.addGestureRecognizer(tapGesture)
    }
    
    // Function to disable annotation mode
    private func disableAnnotationMode() {
        // Implementation for disabling annotation mode
        pdfView.gestureRecognizers?.forEach { gestureRecognizer in
            if gestureRecognizer is UITapGestureRecognizer {
                pdfView.removeGestureRecognizer(gestureRecognizer)
            }
        }
    }
    
    // Handle a tap on the PDF for adding annotations
    @objc private func handleTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: pdfView)
        let page = pdfView.page(for: location, nearest: true)
        
        if let page = page {
            let annotation = PDFAnnotation(bounds: CGRect(x: location.x, y: location.y, width: 200, height: 40), forType: .text, withProperties: nil)
            annotation.contents = "This is a text annotation"
            page.addAnnotation(annotation)
        }
    }
    
    // Handle a double-tap for editing annotations
    @objc private func handleDoubleTap(sender: UITapGestureRecognizer) {
        let location = sender.location(in: pdfView)
        let page = pdfView.page(for: location, nearest: true)
        
        if let page = page {
            let annotations = page.annotations
            for annotation in annotations {
                let annotationRect = pdfView.convert(annotation.bounds, from: page)
                if annotationRect.contains(location) {
                    // Display an editing UI for the selected annotation
                    editAnnotation(annotation)
                }
            }
        }
    }
    
    // Function to display an editing UI for annotations
    private func editAnnotation(_ annotation: PDFAnnotation) {
        // Implement your custom UI for editing annotation content or properties
        let alertController = UIAlertController(title: "Edit Annotation", message: "Modify annotation content", preferredStyle: .alert)
        
        alertController.addTextField { textField in
            textField.text = annotation.contents
        }
        
        let saveAction = UIAlertAction(title: "Save", style: .default) { [weak self] _ in
            if let textField = alertController.textFields?.first, let newText = textField.text {
                annotation.contents = newText
                self?.pdfView.setNeedsDisplay()
            }
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(saveAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - UIDocumentPickerDelegate
extension ViewController: UIDocumentPickerDelegate {
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {
        // Handle the picked document URLs here
        if let documentURL = urls.first {
            // Load and display the selected PDF document using PDFView, or perform other actions.
            pdfView.document = PDFDocument(url: documentURL)
        }
    }
}

// MARK: - UIDocumentBrowserViewControllerDelegate
extension ViewController: UIDocumentBrowserViewControllerDelegate {
    func documentBrowser(_ controller: UIDocumentBrowserViewController, didPickDocumentURLs documentURLs: [URL]) {
        guard let documentURL = documentURLs.first else {
            return
        }

        // Load and display the selected PDF document using PDFView
        pdfView.document = PDFDocument(url: documentURL)
    }

    func documentBrowser(_ controller: UIDocumentBrowserViewController, didRequestDocumentCreationWithHandler importHandler: @escaping (URL?, UIDocumentBrowserViewController.ImportMode) -> Void) {
        // Implement document creation if needed
        // The importHandler should be called when a new document is created and provide its URL.
        // The ImportMode defines how the document is imported.
    }
}
