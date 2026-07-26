import Foundation

enum VocabularySource: String, Equatable, Sendable {
    case cache
    case bundle
    case api
}

enum VocabularyLoadingError: Error, Equatable {
    case unavailable
    case invalidResponse
}

struct LoadedVocabulary: Equatable, Sendable {
    let catalog: VocabularyCatalog
    let source: VocabularySource
}

protocol VocabularyCatalogSource {
    func loadCatalog() async throws -> VocabularyCatalog?
}

struct BundleVocabularySource: VocabularyCatalogSource {
    let url: URL?

    init(bundle: Bundle = .main) {
        url = bundle.url(forResource: "vocabulary", withExtension: "json")
    }

    init(url: URL?) {
        self.url = url
    }

    func loadCatalog() async throws -> VocabularyCatalog? {
        guard let url else { return nil }
        return try JSONDecoder().decode(VocabularyCatalog.self, from: Data(contentsOf: url))
    }
}

struct APIVocabularySource: VocabularyCatalogSource {
    let baseURL: URL?
    var session: URLSession = .shared

    func loadCatalog() async throws -> VocabularyCatalog? {
        guard let baseURL else { return nil }
        let url = baseURL.appending(path: "v1/topics")
        let (data, response) = try await session.data(from: url)
        guard let httpResponse = response as? HTTPURLResponse,
              200..<300 ~= httpResponse.statusCode else {
            throw VocabularyLoadingError.invalidResponse
        }
        return try JSONDecoder().decode(VocabularyCatalog.self, from: data)
    }
}

struct VocabularyLoader {
    let cache: any VocabularyCatalogSource
    let bundle: any VocabularyCatalogSource
    let api: any VocabularyCatalogSource

    func load() async throws -> LoadedVocabulary {
        for (source, provider) in [
            (VocabularySource.cache, cache),
            (.bundle, bundle),
            (.api, api),
        ] {
            do {
                if let catalog = try await provider.loadCatalog(), !catalog.usableTopics.isEmpty {
                    return LoadedVocabulary(catalog: catalog, source: source)
                }
            } catch {
                continue
            }
        }
        throw VocabularyLoadingError.unavailable
    }
}

@MainActor
struct CachedVocabularySource: VocabularyCatalogSource {
    let repository: any PersistenceRepository

    func loadCatalog() async throws -> VocabularyCatalog? {
        try repository.loadCachedVocabulary()
    }
}

struct EmptyVocabularySource: VocabularyCatalogSource {
    func loadCatalog() async throws -> VocabularyCatalog? { nil }
}