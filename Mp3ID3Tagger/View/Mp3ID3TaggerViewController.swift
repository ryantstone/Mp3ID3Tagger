//
//  Mp3ID3TaggerViewController.swift
//  Mp3ID3Tagger
//
//  Created by Fabrizio Duroni on 30.03.18.
//

import Cocoa
import RxSwift
import RxCocoa
import ID3TagEditor

class Mp3ID3TaggerViewController: NSViewController, BindableView {
    private let disposeBag: DisposeBag = DisposeBag()
    private let pathSubject: PublishSubject<String> = PublishSubject<String>()
    private let imageSubject: PublishSubject<Data> = PublishSubject<Data>()
    var viewModel: Mp3ID3TaggerViewModel!
    @IBOutlet weak var versionPopUpbutton: NSPopUpButton!
    @IBOutlet weak var titleTextField: NSTextField!
    @IBOutlet weak var artistTextField: NSTextField!
    @IBOutlet weak var albumTextField: NSTextField!
    @IBOutlet weak var yearTextField: NSTextField!
    @IBOutlet weak var trackPositionTextField: NSTextField!
    @IBOutlet weak var totalTracksTextField: NSTextField!
    @IBOutlet weak var genrePopUpMenu: NSPopUpButton!
    @IBOutlet weak var genreDescriptionTextField: NSTextField!
    @IBOutlet weak var imageSelectionButton: NSButton!
    @IBOutlet weak var updateButton: NSButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.bindViewModel()
    }
    
    func bindViewModel() {
        viewModel = Mp3ID3TaggerViewModel(editor: ID3TagEditor(),
                                          path: pathSubject.asObservable(),
                                          image: imageSubject,
                                          updateAction: updateButton.rx.tap.asObservable())
        (titleTextField.rx.text <-> viewModel.title).disposed(by: disposeBag)
        (artistTextField.rx.text <-> viewModel.artist).disposed(by: disposeBag)
        (albumTextField.rx.text <-> viewModel.album).disposed(by: disposeBag)
        (yearTextField.rx.text <-> viewModel.year).disposed(by: disposeBag)
        (versionPopUpbutton.rx.selectedItemTag <-> viewModel.version).disposed(by: disposeBag)
        (trackPositionTextField.rx.text <-> viewModel.trackPositionInSetFields.trackPosition).disposed(by: disposeBag)
        (totalTracksTextField.rx.text <-> viewModel.trackPositionInSetFields.totalTracks).disposed(by: disposeBag)
        (genrePopUpMenu.rx.selectedItemTag <-> viewModel.genreFields.genreIdentifier).disposed(by: disposeBag)
        (genreDescriptionTextField.rx.text <-> viewModel.genreFields.genreDescription).disposed(by: disposeBag)
        self.bindAttachedPicture()
        self.bindSaveAction()
    }
    
    private func bindAttachedPicture() {
        imageSubject.subscribe(onNext: { self.imageSelectionButton.image = NSImage(data: $0) }).disposed(by: disposeBag)
        imageSelectionButton.rx.tap.subscribe(onNext: { tap in
            NSOpenPanel.display(in: self.view.window!,
                                fileTypes: ["png", "jpg"],
                                title: "Select an Image file",
                                onComplete: { (openPanel, response) in
                                    if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                                        if let selectedUrl = openPanel.url {
                                            let image = try! Data(contentsOf: selectedUrl)
                                            self.imageSubject.onNext(image)
                                            self.imageSelectionButton.image = NSImage(data: image)
                                        }
                                    }
                                }
            )
        })
        .disposed(by: disposeBag)
    }
    
    private func bindSaveAction() {
        viewModel.save
            .asObservable()
            .subscribe(onNext: { (result) in
                let alert = NSAlert()
                alert.addButton(withTitle: "Ok")
                alert.messageText = result ? "Mp3 saved correctly!" : "Error during save!"
                alert.runModal()
            })
            .disposed(by: disposeBag)
    }
    
    @IBAction func openDocument(_ sender: Any?) {
        NSOpenPanel.display(in: self.view.window!,
                            fileTypes: ["mp3"],
                            title: "Select an MP3 file",
                            onComplete: { (openPanel, response) in
                                if response.rawValue == NSApplication.ModalResponse.OK.rawValue {
                                    if let selectedPath = openPanel.url?.path {
                                        self.pathSubject.onNext(selectedPath)
                                    }
                                }
                            }
        )
    }
}

