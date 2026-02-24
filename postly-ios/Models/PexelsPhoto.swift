//
//  PexelsPhoto.swift
//  Postly
//
//  Created by Christian Bonilla on 23/02/26.
//

struct PexelsPhoto: Codable, Identifiable {
    let id: Int
    let photographer: String
    let photographer_url: String
    let src: PhotoSrc
    let alt: String?
}

struct PhotoSrc: Codable {
    let medium: String
    let large: String
}
