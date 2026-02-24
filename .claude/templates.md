# 코드 템플릿

이 파일은 새로운 파일 생성 시 사용할 템플릿을 정의합니다.
"템플릿대로 만들어줘"라고 요청하면 이 파일의 템플릿을 따릅니다.

## 1. SwiftUI View 템플릿

```swift
//
//  {ScreenName}View.swift
//  SeaThermo
//

import SwiftUI

struct {ScreenName}View: View {
    @ObservedObject var viewModel: {ScreenName}ViewModel

    var body: some View {
        ZStack {
            // 배경 (필요시)
            backgroundView
                .ignoresSafeArea()

            // 콘텐츠
            contentView
        }
        .navigationTitle("{화면 제목}")
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.onAppear()
        }
    }

    // MARK: - Views

    private var backgroundView: some View {
        Color.white
    }

    private var contentView: some View {
        VStack(spacing: 16) {
            // TODO: 콘텐츠 구현
        }
        .padding()
    }
}

#Preview {
    NavigationView {
        {ScreenName}View(viewModel: {ScreenName}ViewModel())
    }
}
```

## 2. ViewModel 템플릿 (ObservableObject)

```swift
//
//  {ScreenName}ViewModel.swift
//  SeaThermo
//

import Foundation
import Combine

final class {ScreenName}ViewModel: ObservableObject {

    // MARK: - Published Properties (SwiftUI 바인딩용)

    @Published var items: [ItemType] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?

    // MARK: - Dependencies

    private let useCase: {Feature}UseCase
    private let mainQueue: DispatchQueueType

    // MARK: - Private Properties

    private var loadTask: Cancellable? {
        willSet { loadTask?.cancel() }
    }

    // MARK: - Init

    init(useCase: {Feature}UseCase,
         mainQueue: DispatchQueueType = DispatchQueue.main) {
        self.useCase = useCase
        self.mainQueue = mainQueue
    }

    // MARK: - Public Methods

    func onAppear() {
        fetchData()
    }

    // MARK: - Private Methods

    private func fetchData() {
        isLoading = true

        loadTask = useCase.execute(
            requestValue: .init(),
            completion: { [weak self] result in
                self?.mainQueue.async {
                    self?.isLoading = false

                    switch result {
                    case .success(let data):
                        self?.items = data
                    case .failure(let error):
                        self?.errorMessage = error.localizedDescription
                    }
                }
            }
        )
    }
}
```

## 3. UseCase 템플릿

```swift
//
//  {Feature}UseCase.swift
//  SeaThermo
//

import Foundation

final class {Feature}UseCase {

    // MARK: - Dependencies

    private let repository: {Feature}Repository

    // MARK: - Init

    init(repository: {Feature}Repository) {
        self.repository = repository
    }

    // MARK: - Execute

    struct RequestValue {
        // 요청 파라미터
    }

    func execute(requestValue: RequestValue,
                 completion: @escaping (Result<[Entity], Error>) -> Void) -> Cancellable? {
        return repository.fetch(completion: completion)
    }
}
```

## 4. Repository Protocol 템플릿

```swift
//
//  {Feature}Repository.swift
//  SeaThermo
//

import Foundation

protocol {Feature}Repository {
    func fetch(completion: @escaping (Result<[Entity], Error>) -> Void) -> Cancellable?
    func save(item: Entity, completion: @escaping (Result<Void, Error>) -> Void)
}
```

## 5. Repository Implementation 템플릿

```swift
//
//  Default{Feature}Repository.swift
//  SeaThermo
//

import Foundation

final class Default{Feature}Repository: {Feature}Repository {

    // MARK: - Dependencies

    private let dataTransferService: DataTransferService

    // MARK: - Init

    init(dataTransferService: DataTransferService) {
        self.dataTransferService = dataTransferService
    }

    // MARK: - {Feature}Repository

    func fetch(completion: @escaping (Result<[Entity], Error>) -> Void) -> Cancellable? {
        let endpoint = APIEndpoints.get{Feature}()

        return dataTransferService.request(with: endpoint) { result in
            switch result {
            case .success(let responseDTO):
                completion(.success(responseDTO.toDomain()))
            case .failure(let error):
                completion(.failure(error))
            }
        }
    }

    func save(item: Entity, completion: @escaping (Result<Void, Error>) -> Void) {
        // 저장 로직
    }
}
```

## 6. UIViewRepresentable 템플릿 (UIKit → SwiftUI)

```swift
//
//  {Component}Representable.swift
//  SeaThermo
//

import SwiftUI

struct {Component}Representable: UIViewRepresentable {

    // MARK: - Bindings

    @Binding var data: DataType
    @Binding var shouldCleanup: Bool

    // MARK: - Callbacks

    var onEvent: ((EventType) -> Void)?

    // MARK: - UIViewRepresentable

    func makeUIView(context: Context) -> UIViewType {
        let view = UIViewType()
        view.delegate = context.coordinator
        return view
    }

    func updateUIView(_ uiView: UIViewType, context: Context) {
        if shouldCleanup {
            context.coordinator.cleanup()
            return
        }
        // 데이터 업데이트
    }

    static func dismantleUIView(_ uiView: UIViewType, coordinator: Coordinator) {
        // 메모리 정리
        uiView.delegate = nil
    }

    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }

    // MARK: - Coordinator

    class Coordinator: NSObject {
        var parent: {Component}Representable
        weak var view: UIViewType?

        init(_ parent: {Component}Representable) {
            self.parent = parent
        }

        func cleanup() {
            // 정리 로직
        }

        deinit {
            print("Coordinator deinitialized")
        }
    }
}
```

## 7. DI Container 등록 패턴

```swift
// PointSceneDIContainer.swift에 추가

// MARK: - {Feature}

func make{Feature}ViewModel() -> {Feature}ViewModel {
    {Feature}ViewModel(useCase: make{Feature}UseCase())
}

private func make{Feature}UseCase() -> {Feature}UseCase {
    {Feature}UseCase(repository: make{Feature}Repository())
}

private func make{Feature}Repository() -> {Feature}Repository {
    Default{Feature}Repository(dataTransferService: dependencies.apiDataTransferService)
}
```

## 8. NavigationLink 패턴

```swift
// 기본 NavigationLink
NavigationLink {
    DestinationView(viewModel: pointSceneDIContainer.makeDestinationViewModel())
} label: {
    Text("이동")
}

// 프로그래매틱 NavigationLink
@State private var showDestination = false

NavigationLink(destination: destinationView, isActive: $showDestination) {
    EmptyView()
}

Button("이동") {
    showDestination = true
}
```

## 사용 예시

"새 화면을 템플릿대로 만들어줘" 요청 시:
1. View + ViewModel 쌍 생성
2. DI Container에 등록
3. NavigationLink로 연결
