//
//  MetricKitManager.swift
//  SeaThermo
//
//  OS 종료 진단을 위한 MetricKit 구독 매니저
//  Firebase Crashlytics가 잡지 못하는 SIGKILL 기반 종료 원인을 수집합니다.
//

import MetricKit
import os.log

final class MetricKitManager: NSObject {

    static let shared = MetricKitManager()

    private let logger = Logger(subsystem: "com.onbada.seathermo", category: "MetricKit")

    // UserDefaults 저장 키
    private enum StorageKey {
        static let crashLogs = "metrickit_crash_logs"
        static let hangLogs  = "metrickit_hang_logs"
        static let cpuLogs   = "metrickit_cpu_logs"
        // 비정상 종료 여부 감지용
        static let sessionRunning = "metrickit_session_running"
        static let lastAbnormalTerminationDate = "metrickit_last_abnormal_termination_date"
    }

    private override init() { super.init() }

    // MARK: - 구독 시작 (AppDelegate에서 호출)

    func subscribe() {
        MXMetricManager.shared.add(self)
        markSessionStart()
    }

    // MARK: - 세션 정상 종료 표시 (applicationWillTerminate에서 호출)

    func markSessionEnd() {
        UserDefaults.standard.removeObject(forKey: StorageKey.sessionRunning)
    }

    // MARK: - 이전 세션 비정상 종료 여부 확인

    /// true이면 이전 세션이 정상적으로 종료되지 않았음 (OS 강제 종료 가능성)
    var didPreviousSessionTerminateAbnormally: Bool {
        return UserDefaults.standard.bool(forKey: StorageKey.sessionRunning)
    }

    var lastAbnormalTerminationDate: Date? {
        return UserDefaults.standard.object(forKey: StorageKey.lastAbnormalTerminationDate) as? Date
    }

    // MARK: - 저장된 진단 로그 조회

    func recentCrashLogs() -> [String] { loadLogs(key: StorageKey.crashLogs) }
    func recentHangLogs()  -> [String] { loadLogs(key: StorageKey.hangLogs) }
    func recentCPULogs()   -> [String] { loadLogs(key: StorageKey.cpuLogs) }

    func clearAllLogs() {
        [StorageKey.crashLogs, StorageKey.hangLogs, StorageKey.cpuLogs].forEach {
            UserDefaults.standard.removeObject(forKey: $0)
        }
    }

    // MARK: - Private

    private func markSessionStart() {
        if UserDefaults.standard.bool(forKey: StorageKey.sessionRunning) {
            // 이전 세션이 정상 종료되지 않았음
            let date = Date()
            UserDefaults.standard.set(date, forKey: StorageKey.lastAbnormalTerminationDate)
            logger.warning("⚠️ 이전 세션이 비정상 종료됨 (감지 시점: \(date))")
        }
        UserDefaults.standard.set(true, forKey: StorageKey.sessionRunning)
    }

    private func appendLog(_ entry: String, key: String) {
        var logs = loadLogs(key: key)
        logs.append(entry)
        if logs.count > 20 { logs = Array(logs.suffix(20)) }
        UserDefaults.standard.set(logs, forKey: key)
    }

    private func loadLogs(key: String) -> [String] {
        return UserDefaults.standard.stringArray(forKey: key) ?? []
    }
}

// MARK: - MXMetricManagerSubscriber

extension MetricKitManager: MXMetricManagerSubscriber {

    func didReceive(_ payloads: [MXMetricPayload]) {
        // 성능 메트릭 (배터리, 네트워크 등) - 현재는 로깅만
        logger.debug("MetricKit 성능 페이로드 수신: \(payloads.count)건")
    }

    func didReceive(_ payloads: [MXDiagnosticPayload]) {
        for payload in payloads {
            processDiagnosticPayload(payload)
        }
    }

    private func processDiagnosticPayload(_ payload: MXDiagnosticPayload) {
        let period = "\(payload.timeStampBegin) ~ \(payload.timeStampEnd)"

        // Crash Diagnostics - OS SIGKILL은 여기에 포함되지 않지만 앱 내부 크래시는 수집됨
        for crash in payload.crashDiagnostics ?? [] {
            let entry = """
            [Crash] \(period)
            종료 이유: \(crash.terminationReason ?? "알 수 없음")
            예외 타입: \(crash.exceptionType?.intValue.description ?? "-")
            예외 코드: \(crash.exceptionCode?.intValue.description ?? "-")
            시그널:   \(crash.signal?.intValue.description ?? "-")
            """
            logger.critical("🔴 \(entry)")
            appendLog(entry, key: StorageKey.crashLogs)
        }

        // Hang Diagnostics - 메인 스레드 블로킹 (Watchdog 종료 전조)
        for hang in payload.hangDiagnostics ?? [] {
            let entry = """
            [Hang] \(period)
            지속 시간: \(hang.hangDuration)
            """
            logger.error("🟠 \(entry)")
            appendLog(entry, key: StorageKey.hangLogs)
        }

        // CPU Exception - CPU 과점유로 인한 종료
        for cpu in payload.cpuExceptionDiagnostics ?? [] {
            let entry = """
            [CPU Exception] \(period)
            총 CPU 시간:    \(cpu.totalCPUTime)
            총 샘플링 시간: \(cpu.totalSampledTime)
            """
            logger.error("🟡 \(entry)")
            appendLog(entry, key: StorageKey.cpuLogs)
        }
    }
}
