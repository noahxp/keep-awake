import Foundation
import KeepAwakeLib

// CaffeinateManager core business test registration

func registerCaffeinateManagerTests() {

    // MARK: - Wave 2: start behavior

    // start sets the correct executableURL
    registerTest("test_start_設定正確的executableURL") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)
        try assertEqual(mock.recordedExecutableURL, URL(fileURLWithPath: "/usr/bin/caffeinate"))
    }

    // start sets the correct arguments
    registerTest("test_start_設定正確的arguments") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 1800)
        try assertEqual(mock.recordedArguments, ["-s", "-t", "1800"])
    }

    // start calls run
    registerTest("test_start_調用了run") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)
        try assertTrue(mock.runCalled, "run() 應已被調用")
    }

    // MARK: - Wave 3: isRunning state transitions

    // Initial isRunning is false
    registerTest("test_初始狀態_isRunning為false") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        try assertFalse(manager.isRunning, "初始 isRunning 應為 false")
    }

    // isRunning is true after start
    registerTest("test_start後_isRunning為true") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)
        try assertTrue(manager.isRunning, "start 後 isRunning 應為 true")
    }

    // isRunning becomes false after caffeinate exits
    registerTest("test_caffeinate退出後_isRunning變為false") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)
        try assertTrue(manager.isRunning, "start 後 isRunning 應為 true")

        // Trigger terminationHandler (simulates caffeinate auto-exit on timer expiry)
        mock.simulateTermination()

        // terminationHandler dispatches to main queue; drain it to process the callback
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        try assertFalse(manager.isRunning, "caffeinate 退出後 isRunning 應為 false")
    }

    // MARK: - Wave 4: stop behavior

    // stop calls terminate
    registerTest("test_stop_調用了terminate") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)
        manager.stop()
        try assertTrue(mock.terminateCalled, "terminate() 應已被調用")
    }

    // isRunning is false after stop
    registerTest("test_stop後_isRunning為false") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)
        manager.stop()
        try assertFalse(manager.isRunning, "stop 後 isRunning 應為 false")
    }

    // stop does not crash when nothing is running
    registerTest("test_沒在跑時stop_不崩潰") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        // manager has no process initially; stop should not throw
        manager.stop()
        try assertFalse(manager.isRunning, "初始 stop 後 isRunning 應為 false")
    }

    // MARK: - Wave 4.5: currentSeconds state

    // Initial currentSeconds is nil
    registerTest("test_初始狀態_currentSeconds為nil") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        try assertEqual(manager.currentSeconds, nil as Int?)
    }

    // currentSeconds records the correct value after start
    registerTest("test_start後_currentSeconds記錄正確秒數") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 1800)
        try assertEqual(manager.currentSeconds, 1800)
    }

    // currentSeconds is cleared to nil after stop
    registerTest("test_stop後_currentSeconds為nil") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 3600)
        manager.stop()
        try assertEqual(manager.currentSeconds, nil as Int?)
    }

    // currentSeconds is cleared to nil after caffeinate exits
    registerTest("test_caffeinate退出後_currentSeconds為nil") {
        let mock = MockProcessRunner()
        let manager = CaffeinateManager(processFactory: { mock })
        manager.start(seconds: 300)

        mock.simulateTermination()
        RunLoop.main.run(until: Date(timeIntervalSinceNow: 0.1))

        try assertEqual(manager.currentSeconds, nil as Int?)
    }

    // currentSeconds updates to the new value after switching duration
    registerTest("test_切換時間後_currentSeconds更新") {
        let firstMock = MockProcessRunner()
        let secondMock = MockProcessRunner()
        var currentMock: MockProcessRunner = firstMock
        let manager = CaffeinateManager(processFactory: { currentMock })

        manager.start(seconds: 300)
        try assertEqual(manager.currentSeconds, 300)

        currentMock = secondMock
        manager.start(seconds: 7200)
        try assertEqual(manager.currentSeconds, 7200)
    }

    // MARK: - Wave 5: repeated start (switching duration)

    // start terminates the previous process when already running
    registerTest("test_start時已在跑_會先terminate前一個") {
        let firstMock = MockProcessRunner()
        let secondMock = MockProcessRunner()
        var currentMock: MockProcessRunner = firstMock
        let manager = CaffeinateManager(processFactory: { currentMock })

        // First start
        manager.start(seconds: 300)

        // Switch to the second mock
        currentMock = secondMock

        // Second start; should terminate the first
        manager.start(seconds: 1800)

        try assertTrue(firstMock.terminateCalled, "第一個程序應已被終止")
    }

    // New process has correct parameters when start is called while already running
    registerTest("test_start時已在跑_新process參數正確") {
        let firstMock = MockProcessRunner()
        let secondMock = MockProcessRunner()
        var currentMock: MockProcessRunner = firstMock
        let manager = CaffeinateManager(processFactory: { currentMock })

        manager.start(seconds: 300)

        currentMock = secondMock
        manager.start(seconds: 7200)

        try assertEqual(secondMock.recordedExecutableURL, URL(fileURLWithPath: "/usr/bin/caffeinate"))
        try assertEqual(secondMock.recordedArguments, ["-s", "-t", "7200"])
        try assertTrue(secondMock.runCalled, "新程序的 run() 應已被調用")
    }
}
