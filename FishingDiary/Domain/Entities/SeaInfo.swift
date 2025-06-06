//
//  SeaInfo.swift
//  FishingDiary
//
//  Created by Y0000591 on 4/12/24.
//

import Foundation

enum Sea: String, CaseIterable {
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
    case mokpoDoripo = "목포 도리포"
    case muanSeobug = "무안 서북"
    case muanSeongnae = "무안 성내"
    case baeglyeongdo = "백령도"
    case boryeongSabsido = "보령 삽시도"
    case boryeongHyojado = "보령 효자도"
    case buanByeonsan = "부안 변산"
    case buanWido = "부안 위도"
    case seosanJigog = "서산 지곡"
    case seosanChangli = "서산 창리"
    case seocheonMaryang = "서천 마량"
    case sinanDamuldo = "신안 다물도"
    case sinanDasu = "신안 다수"
    case sinanDaeri = "신안 대리"
    case sinanDocho = "신안 도초"
    case sinanMari = "신안 마리"
    case sinanBanwol = "신안 반월"
    case sinanSari = "신안 사리"
    case sinanSachi = "신안 사치"
    case sinanSonggong = "신안 송공"
    case sinanAnjwa = "신안 안좌"
    case sinanAphae = "신안 압해"
    case sinanEoui = "신안 어의"
    case sinanEubdong = "신안 읍동"
    case sinanJaeun = "신안 자은"
    case sinanJangsan = "신안 장산"
    case sinanHaui = "신안 하의"
    case sinanHeugsan = "신안 흑산"
    case yeonggwangNagwol = "영광 낙월"
    case yeonggwangAnmado = "영광 안마도"
    case yeonggwangYeomsan = "영광 염산"
    case incheonIjagdo = "인천 이작도"
    case incheonJawoldo = "인천 자월도"
    case incheonJangbongdo = "인천 장봉도"
    case jindoGasa = "진도 가사"
    case jindoBuldo = "진도 불도"
    case jindoOgdo = "진도 옥도"
    case jindoJeodo = "진도 저도"
    case jindoJeondu = "진도 전두"
    case taeanNaepo = "태안 내포"
    case taeanDaeyado = "태안 대야도"
    case taeanSinjindo = "태안 신진도"
    case taeanAnmyeondo = "태안 안면도"
    case hampyeongSeogdu = "함평 석두"
    case haenamGunghang = "해남 궁항"
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
        case .mokpoDoripo:
            return "fmdka"
        case .muanSeobug:
            return "fmsm6"
        case .muanSeongnae:
            return "fmsj7"
        case .baeglyeongdo:
            return "fbn69"
        case .boryeongSabsido:
            return "bbsi5"
        case .boryeongHyojado:
            return "br001"
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
        case .sinanDocho:
            return "fsdl7"
        case .sinanMari:
            return "fsmm6"
        case .sinanBanwol:
            return "fsbo4"
        case .sinanSari:
            return "fshl7"
        case .sinanSachi:
            return "fssk8"
        case .sinanSonggong:
            return "fssm6"
        case .sinanAnjwa:
            return "fsaj7"
        case .sinanAphae:
            return "esafc"
        case .sinanEoui:
            return "fsej7"
        case .sinanEubdong:
            return "fsal6"
        case .sinanJaeun:
            return "bsji5"
        case .sinanJangsan:
            return "fsjo4"
        case .sinanHaui:
            return "fsuj7"
        case .sinanHeugsan:
            return "fshj7"
        case .yeonggwangNagwol:
            return "byni5"
        case .yeonggwangAnmado:
            return "fyyl4"
        case .yeonggwangYeomsan:
            return "fyyl4"
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
        case .jindoOgdo:
            return "fjoo4"
        case .jindoJeodo:
            return "fjjka"
        case .jindoJeondu:
            return "fjdfc"
        case .taeanNaepo:
            return "btni5"
        case .taeanDaeyado:
            return "ftdk5"
        case .taeanSinjindo:
            return "btsi5"
        case .taeanAnmyeondo:
            return "btai5"
        case .hampyeongSeogdu:
            return "fhjj7"
        case .haenamGunghang:
            return "fhgm6"
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
    case goseong = "고성 가진"
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
        case .goseong:
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
    case geojeIlun = "거제 일운"
    case geojeHaegeumgang = "거제 해금강"
    case goheungGeumsan = "고흥 금산"
    case goheungNamyeol = "고흥 남열"
    case goheungDongchoh = "고흥 동촌"
    case goheungBalpo = "고흥 발포"
    case goheungBuado = "고흥 부아도"
    case goheungBisado = "고흥 비사도"
    case goheungSorogdo = "고흥 소록도"
    case goheungSisan = "고흥 시산"
    case goheungSinchon = "고흥 신촌"
    case goheungYeonso = "고흥 연소"
    case goheungYeompo = "고흥 염포"
    case goheungYeongnam = "고흥 영남"
    case goheungWolha = "고흥 월하"
    case goheungIggeum = "고흥 익금"
    case goheungJangsu = "고흥 장수"
    case goheungJijug = "고흥 지죽"
    case goheungHwado = "고흥 화도"
    case namhaeGangjin = "남해 강진"
    case namhaeMijo = "남해 미조"
    case namhaeSangju = "남해 상주"
    case boseongDongyul = "보성 동율"
    case boseongYulpo = "보성 율포"
    case boseongHaepyeong = "보성 해평"
    case busanDadaepo = "부산 다대포"
    case westJeju = "서제주"
    case yeosuGunnae = "여수 군내"
    case yeosuGeumodo = "여수 금오도"
    case yeosuNabal = "여수 나발"
    case yeosuNajin = "여수 나진"
    case yeosuDaeyul = "여수 대율"
    case yeosuDeogchon = "여수 덕촌"
    case yeosuDolsan = "여수 돌산"
    case yeosuBaegya = "여수 백야"
    case yeosuSonggo = "여수 송고"
    case yeosuSinwol = "여수 신월"
    case yeosuSinwol2 = "여수 신월2"
    case yeosuYeoja = "여수 여자"
    case yeosuWolho = "여수 월호"
    case yeosuJedo = "여수 제도"
    case yeosuJungang = "여수 중앙"
    case yeosuHangdae = "여수 항대"
    case yeosuHwasan = "여수 화산"
    case yeosuHwatae = "여수 화태"
    case wandoGagyo = "완도 가교"
    case wandoGahag = "완도 가학"
    case wandoGoma = "완도 고마"
    case wandoGunoe = "완도 군외"
    case wandoGeumil = "완도 금일"
    case wandoNohwado = "완도 노화도"
    case wandoDangmog = "완도 당목"
    case wandoDangin = "완도 당인"
    case wandoDeogdong = "완도 덕동"
    case wandoDongBaeg = "완도 동백"
    case wandoDongchon = "완도 동촌"
    case wandoMangnam = "완도 망남"
    case wandoModong = "완도 모동"
    case wandoMira = "완도 미라"
    case wandoBangchug = "완도 방축"
    case wandoBaegdo = "완도 백도"
    case wandoSonggog = "완도 송곡"
    case wandoSinheung = "완도 신흥"
    case wandoYangji = "완도 양지"
    case wandoYesong = "완도 예송"
    case wandoIljeong = "완도 일정"
    case wandoJungdo = "완도 중도"
    case wandoCheongsan = "완도 청산"
    case wandoHoeryong = "완도 회룡"
    case wandoHoenggan = "완도 횡간"
    case jangheungNaejeo = "장흥 내저"
    case jangheungNoryeog = "장흥 노력"
    case jangheungSachon = "장흥 사촌"
    case jangheungIjinmog = "장흥 이진목"
    case jangheungHoejin = "장흥 회진"
    case jejuGapado = "제주 가파도"
    case jejuGimnyeong = "제주 김녕"
    case jejuSinsan = "제주 신산"
    case jejuYeonglag = "제주 영락"
    case jejuYongdam = "제주 용담"
    case jejuUdo = "제주 우도"
    case jejuJungmun = "제주 중문"
    case jejuHyeobje = "제주 협제"
    case jindoGeumgab = "진도 금갑"
    case jindoDomog = "진도 도목"
    case jindoModo = "진도 모도"
    case jindoBulmudo = "진도 불무도"
    case jindoSinjeon = "진도 신전"
    case jindoJodo = "진도 조도"
    case jindoHoeding = "진도 회동"
    case jindoJamdo = "진도 잠도"
    case chujado = "추자도"
    case tongyeongDumido = "통영 두미도"
    case tongyeongBisando = "통영 비산도"
    case tongyeongSaryang = "통영 사량"
    case tongyeongSomaemuldo = "통영 소매물도"
    case tongyeongSuwol = "통영 수월"
    case tongyeongYeonhwado = "통영 연화도"
    case tongyeongYeongun = "통영 영운"
    case tongyeongPunghwa = "통영 풍화"
    case tongyeongHaglim = "통영 학림"
    case tongyeongHansando = "통영 한산도"
    case haenamNamseong = "해남 남성"
    case haenamBugil = "해남 북일"
    case haenamSamjeong = "해남 삼정"
    case haenamSangma = "해남 상마"
    case haenamSongji = "해남 송지"
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
        case .geojeIlun:
            return "gi086"
        case .geojeHaegeumgang:
            return "btei5"
        case .goheungGeumsan:
            return "fggm6"
        case .goheungNamyeol:
            return "fgnm6"
        case .goheungDongchoh:
            return "fgdl4"
        case .goheungBalpo:
            return "fgpo4"
        case .goheungBuado:
            return "bgui5"
        case .goheungBisado:
            return "fgbo4"
        case .goheungSorogdo:
            return "fgsj3"
        case .goheungSisan:
            return "fgso4"
        case .goheungSinchon:
            return "fgsl4"
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
        case .goheungJangsu:
            return "fgjk5"
        case .goheungJijug:
            return "fgjm6"
        case .goheungHwado:
            return "fghk5"
        case .namhaeGangjin:
            return "eng5c"
        case .namhaeMijo:
            return "fnm5b"
        case .namhaeSangju:
            return "bnsi5"
        case .boseongDongyul:
            return "fbdka"
        case .boseongYulpo:
            return "fbyl6"
        case .boseongHaepyeong:
            return "fbhl7"
        case .busanDadaepo:
            return "bbdi5"
        case .westJeju:
            return "ejj47"
        case .yeosuGunnae:
            return "fygl4"
        case .yeosuGeumodo:
            return "byki5"
        case .yeosuNabal:
            return "fybm6"
        case .yeosuNajin:
            return "fynm6"
        case .yeosuDaeyul:
            return "fydl4"
        case .yeosuDeogchon:
            return "fycm6"
        case .yeosuDolsan:
            return "fydo4"
        case .yeosuBaegya:
            return "fybo4"
        case .yeosuSonggo:
            return "fysl4"
        case .yeosuSinwol:
            return "km001"
        case .yeosuSinwol2:
            return "fysk9"
        case .yeosuYeoja:
            return "fyym6"
        case .yeosuWolho:
            return "fywo4"
        case .yeosuJedo:
            return "fyjkc"
        case .yeosuJungang:
            return "fyjo4"
        case .yeosuHangdae:
            return "fyhl7"
        case .yeosuHwasan:
            return "fyhm6"
        case .yeosuHwatae:
            return "yj087"
        case .wandoGagyo:
            return "fwgf1"
        case .wandoGahag:
            return "fwgm6"
        case .wandoGoma:
            return "fwgk8"
        case .wandoGunoe:
            return "fwgk5"
        case .wandoGeumil:
            return "wk094"
        case .wandoNohwado:
            return "wn087"
        case .wandoDangmog:
            return "fwao4"
        case .wandoDangin:
            return "fwio4"
        case .wandoDeogdong:
            return "fwdo4"
        case .wandoDongBaeg:
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
        case .wandoHoenggan:
            return "fwhm6"
        case .jangheungNaejeo:
            return "fjnk6"
        case .jangheungNoryeog:
            return "fjnka"
        case .jangheungSachon:
            return "fjskb"
        case .jangheungIjinmog:
            return "fjil6"
        case .jangheungHoejin:
            return "ejhfc"
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
        case .jejuHyeobje:
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
        case .jindoHoeding:
            return "fjhk9"
        case .jindoJamdo:
            return "btji5"
        case .chujado:
            return "bcji5"
        case .tongyeongDumido:
            return "btdi5"
        case .tongyeongBisando:
            return "tb087"
        case .tongyeongSaryang:
            return "ty005"
        case .tongyeongSomaemuldo:
            return "btoi5"
        case .tongyeongSuwol:
            return "ftsj3"
        case .tongyeongYeonhwado:
            return "btyi5"
        case .tongyeongYeongun:
            return "ty004"
        case .tongyeongPunghwa:
            return "ftp4c"
        case .tongyeongHaglim:
            return "fth59"
        case .tongyeongHansando:
            return "bthi5"
        case .haenamNamseong:
            return "fhno4"
        case .haenamBugil:
            return "fhbl6"
        case .haenamSamjeong:
            return "fhso4"
        case .haenamSangma:
            return "fhsk7"
        case .haenamSongji:
            return "fhsm6"
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
