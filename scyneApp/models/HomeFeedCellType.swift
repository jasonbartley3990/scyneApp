//
//  HomeFeedCellType.swift
//  scyneApp
//
//  Created by Jason bartley on 5/6/21.
//

import Foundation

enum HomeFeedCellType {
    case poster(viewModel: PosterCollectionViewCellviewModel)
    case post(viewModel: PostCollectionViewCellViewModel)
    case postActions(viewModel: PostActionsCollectionViewCellViewModel)
    case caption(viewModel: PostCaptionCollectionViewCellModel)
    case timeStamp(viewModel: PostDateTimeCollectionViewCellViewModel)
    case newSpot(viewModel: SpotHeaderCollectionViewCellModel)
    case spotAction(viewModel: SpotActionsCollectionViewCellViewModel)
    case address(viewModel: SpotAddressCollectionViewCellViewModel)
    case uploader(viewModel: SpotUploaderCollectionViewCellViewModel)
    case gearAction(viewModel: gearActionsCollectionViewCellViewModel)
    case title(viewModel: TitleCollectionViewCellViewModel)
    case fullLengthAction(viewModel: fullLengthActionCellViewModel)
    case MultiPhoto(viewModel: MultiPhotoCollectionViewCelViewModel)
    case singleVideo(viewModel: SingleVideoCollectionViewCellViewModel)
    case fullLengthPoster(viewModel: fullLengthPosterCollectionViewCellViewModel)
    case fullLengthTitle(viewModel: fullLengthTitleCollectionViewCellViewModel)
    case normalPostAction(viewModel: normalPostActionsCollectionViewCellViewModel)
    case advertisementLink(viewModel: AdvertisementWebLinkViewModel)
    case advertisementheader(viewModel: advertisementHeaderViewModel)
    case AdPageTurner(viewModel: AdvertisementPageTurnerViewModel)
    
}
