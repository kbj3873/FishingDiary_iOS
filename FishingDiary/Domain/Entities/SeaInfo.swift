//
//  SeaInfo.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/12/24.
//

import Foundation

enum Sea: String, CaseIterable, Identifiable {
    case none = "선택"
    case west = "서해"
    case east = "동해"
    case south = "남해"
    
    var id: String {
        switch self {
        case .none:
            return ""
        case .west:
            return "W"
        case .east:
            return "E"
        case .south:
            return "S"
        }
    }
}

protocol Observ {
    var cd: String { get }
    var title: String { get }
}

enum WestObserv: String, Observ, CaseIterable {
    case none = "선택"
    case gunsanBiando = "군산 비안도"
    case gunsanSinsido = "군산 신시도"
    case gunsanHoenggyeongdo = "군산 횡경도"
    case mokpo = "목포"
    case mokpoOedal = "목포 외달"
    case muanDoripo = "무안 도리포"
    case muanSeobug = "무안 서북"
    case muanSeongnae = "무안 성내"
    case baeglyeongdo = "백령도"
    case boryeongSabsido = "보령 삽시도"
    case boryeongSodo = "보령 소도"
    case buanByeonsan = "부안 변산"
    case buanWido = "부안 위도"
    case seosanJigog = "서산 지곡"
    case seosanChangli = "서산 창리"
    case seocheonMaryang = "서천 마량"
    case sinanDamuldo = "신안 다물도"
    case sinanDasu = "신안 다수"
    case sinanDaeri = "신안 대리"
    case sinanMari = "신안 마리"
    case sinanBanwol = "신안 반월"
    case sinanSosin = "신안 소신"
    case sinanSonggong = "신안 송공"
    case sinanAnjwa = "신안 안좌"
    case sinanEoui = "신안 어의"
    case sinanEubdong = "신안 읍동"
    case sinanJangsan = "신안 장산"
    case sinanHeugsan = "신안 흑산"
    case yeonggwangNagwol = "영광 낙월"
    case yeonggwangAnmado = "영광 안마도"
    case incheonIjagdo = "인천 이작도"
    case incheonJawoldo = "인천 자월도"
    case incheonJangbongdo = "인천 장봉도"
    case jindoGasa = "진도 가사"
    case jindoBuldo = "진도 불도"
    case taeanGonam = "태안 고남"
    case taeanNaepo = "태안 내포"
    case taeanDaeyado = "태안 대야도"
    case taeanSinjindo = "태안 신진도"
    case taeanAnmyeondo = "태안 안면도"
    case taeanPadori = "태안 파도리"
    case haenamMunnae = "해남 문내"
    case haenamImha = "해남 임하"
    
    var cd: String {
        switch self {
        case .none:
            return ""
        case .gunsanBiando:
            return "bgbi5"
        case .gunsanSinsido:
            return "egsi4"
        case .gunsanHoenggyeongdo:
            return "bghi5"
        case .mokpo:
            return "emp67"
        case .mokpoOedal:
            return "fmoj7"
        case .muanDoripo:
            return "fmdka"
        case .muanSeobug:
            return "fmsm6"
        case .muanSeongnae:
            return "fmsj7"
        case .baeglyeongdo:
            return "fbn69"
        case .boryeongSabsido:
            return "bbsi5"
        case .boryeongSodo:
            return "fbsp5"
        case .buanByeonsan:
            return "bbbi5"
        case .buanWido:
            return "bbwi5"
        case .seosanJigog:
            return "sj086"
        case .seosanChangli:
            return "fsch6"
        case .seocheonMaryang:
            return "bsmi5"
        case .sinanDamuldo:
            return "fsdk7"
        case .sinanDasu:
            return "fsdk6"
        case .sinanDaeri:
            return "fshl6"
        case .sinanMari:
            return "fsmm6"
        case .sinanBanwol:
            return "fsbo4"
        case .sinanSosin:
            return "fssoc"
        case .sinanSonggong:
            return "fssm6"
        case .sinanAnjwa:
            return "fsaj7"
        case .sinanEoui:
            return "fsej7"
        case .sinanEubdong:
            return "fsal6"
        case .sinanJangsan:
            return "fsjo4"
        case .sinanHeugsan:
            return "fshj7"
        case .yeonggwangNagwol:
            return "byni5"
        case .yeonggwangAnmado:
            return "byai5"
        case .incheonIjagdo:
            return "biii5"
        case .incheonJawoldo:
            return "biai5"
        case .incheonJangbongdo:
            return "biji5"
        case .jindoGasa:
            return "fjgk8"
        case .jindoBuldo:
            return "bjbi5"
        case .taeanGonam:
            return "br001"
        case .taeanNaepo:
            return "btni5"
        case .taeanDaeyado:
            return "ftdk5"
        case .taeanSinjindo:
            return "btsi5"
        case .taeanAnmyeondo:
            return "btai5"
        case .taeanPadori:
            return "ftpk5"
        case .haenamMunnae:
            return "fhml6"
        case .haenamImha:
            return "fjh5a"
        }
    }
    
    var title: String {
        return rawValue
    }
}

enum EastObserv: String, Observ, CaseIterable {
    case none = "선택"
    case gangneung = "강릉"
    case gori = "고리"
    case goseongGajin = "고성 가진"
    case guryongpoHajeong = "구룡포 하정"
    case gijang = "기장"
    case gijangHansuwon = "기장(한수원)"
    case nagog = "나곡"
    case deogcheon = "덕천"
    case busanJangan = "부산 장안"
    case samcheog = "삼척"
    case yangyang = "양양"
    case yeongdeog = "영덕"
    case onyang = "온양"
    case ulsanGanjeolgoj = "울산 간절곶"
    case uljinHupo = "울진 후포"
    case jinha = "진하"
    case pohangWolpo = "포항 월포"
    
    var cd: String {
        switch self {
        case .none:
            return ""
        case .gangneung:
            return "bgna3"
        case .gori:
            return "bgrh3"
        case .goseongGajin:
            return "fggo3"
        case .guryongpoHajeong:
            return "fghe8"
        case .gijang:
            return "bgj8a"
        case .gijangHansuwon:
            return "bgjh3"
        case .nagog:
            return "bngh3"
        case .deogcheon:
            return "bdch3"
        case .busanJangan:
            return "bbji5"
        case .samcheog:
            return "bsc87"
        case .yangyang:
            return "byy87"
        case .yeongdeog:
            return "byd8a"
        case .onyang:
            return "byyh3"
        case .ulsanGanjeolgoj:
            return "bugi5"
        case .uljinHupo:
            return "buhi5"
        case .jinha:
            return "bjhh3"
        case .pohangWolpo:
            return "bpwi5"
        }
    }
    
    var title: String {
        return rawValue
    }
}

enum SouthObserv: String, Observ, CaseIterable {
    case none = "선택"
    case gangjinMaryang = "강진 마량"
    case gangjinSacho = "강진 사초"
    case geojeGabae = "거제 가배"
    case geojeGabae2 = "거제 가배2"
    case geojeIlun = "거제 일운"
    case geojeHaegeumgang = "거제 해금강"
    case goheungGeumsan = "고흥 금산"
    case goheungNamyeol = "고흥 남열"
    case goheungDongchon = "고흥 동촌"
    case goheungBuado = "고흥 부아도"
    case goheungSorogdo = "고흥 소록도"
    case goheungSisan = "고흥 시산"
    case goheungYeonso = "고흥 연소"
    case goheungYeompo = "고흥 염포"
    case goheungYeongnam = "고흥 영남"
    case goheungWolha = "고흥 월하"
    case goheungIggeum = "고흥 익금"
    case goheungJijug = "고흥 지죽"
    case namhaeGangjin = "남해 강진"
    case namhaeMijo = "남해 미조"
    case namhaeSangju = "남해 상주"
    case namhaeSeolcheon = "남해 설천"
    case namhaeChangseon = "남해 창선"
    case boseongDongyul = "보성 동율"
    case boseongHaepyeong = "보성 해평"
    case busanDadaepo = "부산 다대포"
    case sacheonBito1 = "사천 비토1"
    case sacheonBito2 = "사천 비토2"
    case sacheonBito3 = "사천 비토3"
    case sacheonWoldeung1 = "사천 월등1"
    case sacheonWoldeung2 = "사천 월등2"
    case westJeju = "서제주"
    case yeosuGunnae = "여수 군내"
    case yeosuGeumodo = "여수 금오도"
    case yeosuNajin = "여수 나진"
    case yeosuDolsan = "여수 돌산"
    case yeosuDongdu = "여수 동두"
    case yeosuBaegya = "여수 백야"
    case yeosuSinwol = "여수 신월"
    case yeosuSinwol2 = "여수 신월2"
    case yeosuYeoja = "여수 여자"
    case yeosuWolho = "여수 월호"
    case yeosuJungang = "여수 중앙"
    case yeosuHangdae = "여수 항대"
    case yeosuHwatae = "여수 화태"
    case wandoGagyo = "완도 가교"
    case wandoGahag = "완도 가학"
    case wandoGammog = "완도 감목"
    case wandoGoma = "완도 고마"
    case wandoGunoe = "완도 군외"
    case wandoGeumil = "완도 금일"
    case wandoNaeri = "완도 내리"
    case wandoNohwado = "완도 노화도"
    case wandoDangmog = "완도 당목"
    case wandoDangin = "완도 당인"
    case wandoDaechang = "완도 대창"
    case wandoDeogdong = "완도 덕동"
    case wandoDongbaeg = "완도 동백"
    case wandoDongchon = "완도 동촌"
    case wandoMangnam = "완도 망남"
    case wandoModong = "완도 모동"
    case wandoMira = "완도 미라"
    case wandoBangchug = "완도 방축"
    case wandoBaegdo = "완도 백도"
    case wandoSadong = "완도 사동"
    case wandoSonggog = "완도 송곡"
    case wandoSinheung = "완도 신흥"
    case wandoYangji = "완도 양지"
    case wandoYesong = "완도 예송"
    case wandoIljeong = "완도 일정"
    case wandoJungdo = "완도 중도"
    case wandoCheongsan = "완도 청산"
    case wandoHoeryong = "완도 회룡"
    case jangheungNaejeo = "장흥 내저"
    case jangheungNoryeog = "장흥 노력"
    case jangheungIjinmog = "장흥 이진목"
    case jejuGapado = "제주 가파도"
    case jejuGimnyeong = "제주 김녕"
    case jejuSinsan = "제주 신산"
    case jejuYeonglag = "제주 영락"
    case jejuYongdam = "제주 용담"
    case jejuUdo = "제주 우도"
    case jejuJungmun = "제주 중문"
    case jejuHyeobjae = "제주 협재"
    case jindoGeumgab = "진도 금갑"
    case jindoDomog = "진도 도목"
    case jindoModo = "진도 모도"
    case jindoBulmudo = "진도 불무도"
    case jindoSinjeon = "진도 신전"
    case jindoJodo = "진도 조도"
    case jindoHoedong = "진도 회동"
    case jinhaeJamdo = "진해 잠도"
    case chujado = "추자도"
    case tongyeongGolli = "통영 곤리"
    case tongyeongDongjwa = "통영 동좌"
    case tongyeongDumido = "통영 두미도"
    case tongyeongMosang = "통영 모상"
    case tongyeongBisando = "통영 비산도"
    case tongyeongSaryang = "통영 사량"
    case tongyeongSamdeog1 = "통영 삼덕1"
    case tongyeongSamdeog2 = "통영 삼덕2"
    case tongyeongSamdeog3 = "통영 삼덕3"
    case tongyeongSuwol = "통영 수월"
    case tongyeongYeonhwado = "통영 연화도"
    case tongyeongYeongun = "통영 영운"
    case tongyeongYogji = "통영 욕지"
    case tongyeongJeolim = "통영 저림"
    case tongyeongPunghwa = "통영 풍화"
    case tongyeongHaglim = "통영 학림"
    case tongyeongHansando = "통영 한산도"
    case tongyeongHambag = "통영 함박"
    case tongyeongHaeran = "통영 해란"
    case haenamSamjeong = "해남 삼정"
    case haenamSongho = "해남 송호"
    case haenamEoran = "해남 어란"
    case haenamOgdong = "해남 옥동"
    case haenamHagga = "해남 학가"
    case haenamHwasan = "해남 화산"
    case haenamHwangsan = "해남 황산"
    
    var cd: String {
        switch self {
        case .none:
            return ""
        case .gangjinMaryang:
            return "fgmk6"
        case .gangjinSacho:
            return "fgsl6"
        case .geojeGabae:
            return "fgg4c"
        case .geojeGabae2:
            return "fggp7"
        case .geojeIlun:
            return "gi086"
        case .geojeHaegeumgang:
            return "btei5"
        case .goheungGeumsan:
            return "fggm6"
        case .goheungNamyeol:
            return "fgnm6"
        case .goheungDongchon:
            return "fgdl4"
        case .goheungBuado:
            return "bgui5"
        case .goheungSorogdo:
            return "fgsj3"
        case .goheungSisan:
            return "fgso4"
        case .goheungYeonso:
            return "fgyl4"
        case .goheungYeompo:
            return "fgyo4"
        case .goheungYeongnam:
            return "fgym6"
        case .goheungWolha:
            return "fgwo4"
        case .goheungIggeum:
            return "fgim6"
        case .goheungJijug:
            return "fgjm6"
        case .namhaeGangjin:
            return "eng5c"
        case .namhaeMijo:
            return "fnm5b"
        case .namhaeSangju:
            return "bnsi5"
        case .namhaeSeolcheon:
            return "fnsp7"
        case .namhaeChangseon:
            return "fncp7"
        case .boseongDongyul:
            return "fbdka"
        case .boseongHaepyeong:
            return "fbhl7"
        case .busanDadaepo:
            return "bbdi5"
        case .sacheonBito1:
            return "fsboa"
        case .sacheonBito2:
            return "fsdoa"
        case .sacheonBito3:
            return "fscoa"
        case .sacheonWoldeung1:
            return "fswoa"
        case .sacheonWoldeung2:
            return "fsxoa"
        case .westJeju:
            return "ejj47"
        case .yeosuGunnae:
            return "fygl4"
        case .yeosuGeumodo:
            return "byki5"
        case .yeosuNajin:
            return "fynm6"
        case .yeosuDolsan:
            return "fydo4"
        case .yeosuDongdu:
            return "fydo9"
        case .yeosuBaegya:
            return "fybo4"
        case .yeosuSinwol:
            return "km001"
        case .yeosuSinwol2:
            return "fysk9"
        case .yeosuYeoja:
            return "fyym6"
        case .yeosuWolho:
            return "fywo4"
        case .yeosuJungang:
            return "fyjo4"
        case .yeosuHangdae:
            return "fyhl7"
        case .yeosuHwatae:
            return "fyho5"
        case .wandoGagyo:
            return "fwgf1"
        case .wandoGahag:
            return "fwgm6"
        case .wandoGammog:
            return "fwyo5"
        case .wandoGoma:
            return "fwgk8"
        case .wandoGunoe:
            return "fwgk5"
        case .wandoGeumil:
            return "wk094"
        case .wandoNaeri:
            return "fwnm6"
        case .wandoNohwado:
            return "wn087"
        case .wandoDangmog:
            return "fwao4"
        case .wandoDangin:
            return "fwio4"
        case .wandoDaechang:
            return "fwdo5"
        case .wandoDeogdong:
            return "fwdo4"
        case .wandoDongbaeg:
            return "fwdf1"
        case .wandoDongchon:
            return "fwdk7"
        case .wandoMangnam:
            return "fwmg3"
        case .wandoModong:
            return "fwmo4"
        case .wandoMira:
            return "fwmk5"
        case .wandoBangchug:
            return "fwbl6"
        case .wandoBaegdo:
            return "fwbf1"
        case .wandoSadong:
            return "fwso5"
        case .wandoSonggog:
            return "fwsm6"
        case .wandoSinheung:
            return "fwsl6"
        case .wandoYangji:
            return "fwyo4"
        case .wandoYesong:
            return "fwyl6"
        case .wandoIljeong:
            return "fwih6"
        case .wandoJungdo:
            return "fwjl6"
        case .wandoCheongsan:
            return "wc001"
        case .wandoHoeryong:
            return "fwho4"
        case .jangheungNaejeo:
            return "fjnk6"
        case .jangheungNoryeog:
            return "fjnka"
        case .jangheungIjinmog:
            return "fjil6"
        case .jejuGapado:
            return "bjgi5"
        case .jejuGimnyeong:
            return "bjii5"
        case .jejuSinsan:
            return "bjsi5"
        case .jejuYeonglag:
            return "bjoi5"
        case .jejuYongdam:
            return "bjyi5"
        case .jejuUdo:
            return "bjui5"
        case .jejuJungmun:
            return "bjni5"
        case .jejuHyeobjae:
            return "bjhi5"
        case .jindoGeumgab:
            return "fjgl6"
        case .jindoDomog:
            return "fjdl4"
        case .jindoModo:
            return "fjmm6"
        case .jindoBulmudo:
            return "bjli5"
        case .jindoSinjeon:
            return "fjsm6"
        case .jindoJodo:
            return "bjji5"
        case .jindoHoedong:
            return "fjhk9"
        case .jinhaeJamdo:
            return "btji5"
        case .chujado:
            return "bcji5"
        case .tongyeongGolli:
            return "ftgp7"
        case .tongyeongDongjwa:
            return "ftdp7"
        case .tongyeongDumido:
            return "btdi5"
        case .tongyeongMosang:
            return "ftmp7"
        case .tongyeongBisando:
            return "tb087"
        case .tongyeongSaryang:
            return "ty005"
        case .tongyeongSamdeog1:
            return "ftup7"
        case .tongyeongSamdeog2:
            return "fttp7"
        case .tongyeongSamdeog3:
            return "ftsp7"
        case .tongyeongSuwol:
            return "ftsj3"
        case .tongyeongYeonhwado:
            return "btyi5"
        case .tongyeongYeongun:
            return "ty004"
        case .tongyeongYogji:
            return "ftyp7"
        case .tongyeongJeolim:
            return "ftjp7"
        case .tongyeongPunghwa:
            return "ftp4c"
        case .tongyeongHaglim:
            return "fth59"
        case .tongyeongHansando:
            return "bthi5"
        case .tongyeongHambag:
            return "fthp7"
        case .tongyeongHaeran:
            return "ftrp7"
        case .haenamSamjeong:
            return "fhso4"
        case .haenamSongho:
            return "fhsk5"
        case .haenamEoran:
            return "fhyk7"
        case .haenamOgdong:
            return "fhom6"
        case .haenamHagga:
            return "fhhk5"
        case .haenamHwasan:
            return "fhhfc"
        case .haenamHwangsan:
            return "fhhl6"
        }
    }
    
    var title: String {
        return rawValue
    }
}

