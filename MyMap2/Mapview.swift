//
//  MapView.swift
//  MyMap
//
//  Created by 木村朋広 on 2024/02/07.
//

import SwiftUI
import MapKit

// 画面で選択したマップの種類を示す列挙型
enum MapType {
    case standard   //標準
    case satellite  //衛星写真
    case hybrid     //衛星写真＋交通機関ラベル
}

struct MapView: View {
    //検索キーワード
    let searchKey: String
    // マップ種類
    let mapType: MapType
    // キーワードから取得した緯度経度
    @State var targetCoordinate = CLLocationCoordinate2D()
//　表示するマップの位置
    @State var cameraPosition:MapCameraPosition = .automatic
//表示するマップのスタイル
    var mapStyle: MapStyle {
        switch mapType {
        case .standard:
            return MapStyle.standard()
        case .satellite:
            return MapStyle.imagery()
        case .hybrid:
            return MapStyle.hybrid()
        }
    }

    var body: some View {
        // マップを表示
        Map(position: $cameraPosition){
            //マップにピンを表示
            Marker(searchKey, coordinate: targetCoordinate)
        }
        // マップのスタイルを指定
        .mapStyle(mapStyle)
        //検索キーワードの変更を検知
        .onChange(of: searchKey, initial: true) { oldValue, newValue in
            //入力されたキーワードをでバックエリアに表示
            print("検索キーワード：\(newValue)")

            // 地図の検索クエリ(命令)の作成
            let request = MKLocalSearch.Request()
            // 検索クエリにキーワードの設定
            request.naturalLanguageQuery = newValue
            //MKLocalSearchの初期化
            let search = MKLocalSearch(request: request)

            //検索の開始
            search.start { response, error in
                // 結果が存在する時は、1件目を取り出す
                if let mapItems = response?.mapItems,
                   let mapItem = mapItems.first {

                    // 位置情報から緯度経度をtargetCoordinateに取り出す
                    targetCoordinate = mapItem.placemark.coordinate

                    // 経度緯度をデバックエリアに表示
                    print("緯度経度：\(targetCoordinate)")

                    // 表示するマップの領域を作成
                    cameraPosition = .region(MKCoordinateRegion(
                        center : targetCoordinate,
                        latitudinalMeters: 500.0,
                        longitudinalMeters: 500.0
                    ))
                } //if ここまで
            } // search.start ここまで
        } //onChange ここまで
    } //body ここまで
} //MapView ここまで

#Preview {
    MapView(searchKey: "東京駅", mapType:.standard)
}

