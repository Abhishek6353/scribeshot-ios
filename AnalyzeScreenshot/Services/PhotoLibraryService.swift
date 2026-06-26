import Foundation
import Photos
import UIKit
import Combine

@MainActor
final class PhotoLibraryService: NSObject, ObservableObject {
    static let shared = PhotoLibraryService()

    @Published var authorizationStatus: PHAuthorizationStatus = .notDetermined
    @Published var newScreenshotIdentifiers: [String] = []

    override init() {
        super.init()
        let status = PHPhotoLibrary.authorizationStatus(for: .readWrite)
        self.authorizationStatus = status
        if status == .authorized || status == .limited {
            PHPhotoLibrary.shared().register(self)
        }
    }

    func requestAuthorization() async -> Bool {
        let status = await PHPhotoLibrary.requestAuthorization(for: .readWrite)
        authorizationStatus = status

        if status == .authorized || status == .limited {
            PHPhotoLibrary.shared().register(self)
            return true
        }
        return false
    }

    func fetchRecentScreenshots(limit: Int = 50) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.sortDescriptors = [NSSortDescriptor(key: "creationDate", ascending: false)]
        options.fetchLimit = limit
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        return PHAsset.fetchAssets(with: .image, options: options)
    }

    func fetchScreenshotsFromIdentifiers(_ identifiers: [String]) -> PHFetchResult<PHAsset> {
        let options = PHFetchOptions()
        options.predicate = NSPredicate(format: "(mediaSubtype & %d) != 0", PHAssetMediaSubtype.photoScreenshot.rawValue)
        let assets = PHAsset.fetchAssets(withLocalIdentifiers: identifiers, options: options)
        return assets
    }

    func requestImage(for asset: PHAsset, targetSize: CGSize) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: targetSize,
                contentMode: .aspectFill,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }

    func requestFullImage(for asset: PHAsset) async -> UIImage? {
        let options = PHImageRequestOptions()
        options.deliveryMode = .highQualityFormat
        options.isNetworkAccessAllowed = false
        options.isSynchronous = false

        return await withCheckedContinuation { continuation in
            PHImageManager.default().requestImage(
                for: asset,
                targetSize: PHImageManagerMaximumSize,
                contentMode: .aspectFit,
                options: options
            ) { image, _ in
                continuation.resume(returning: image)
            }
        }
    }
}

extension PhotoLibraryService: PHPhotoLibraryChangeObserver {
    func photoLibraryDidChange(_ changeInstance: PHChange) {
        Task { @MainActor in
            let fetchResult = fetchRecentScreenshots(limit: 30)
            var identifiers: [String] = []
            fetchResult.enumerateObjects { asset, _, _ in
                identifiers.append(asset.localIdentifier)
            }
            newScreenshotIdentifiers = identifiers
        }
    }
}
