import Foundation
import KeepAwakeLib

// LoginItemManager login item business test registration

func registerLoginItemManagerTests() {

    // MARK: - Initial state

    // Initial state reads false from service
    registerTest("test_初始狀態_service未登記_isEnabled為false") {
        let mock = MockLoginItemService()
        mock.mockIsRegistered = false
        let manager = LoginItemManager(service: mock)
        try assertFalse(manager.isEnabled, "初始 isEnabled 應從 service 讀取為 false")
    }

    // Initial state reads true from service (e.g. previously registered)
    registerTest("test_初始狀態_service已登記_isEnabled為true") {
        let mock = MockLoginItemService()
        mock.mockIsRegistered = true
        let manager = LoginItemManager(service: mock)
        try assertTrue(manager.isEnabled, "初始 isEnabled 應從 service 讀取為 true")
    }

    // MARK: - setEnabled(true) — enable

    // Calls register when enabled
    registerTest("test_setEnabled_true_調用register") {
        let mock = MockLoginItemService()
        let manager = LoginItemManager(service: mock)
        manager.setEnabled(true)
        try assertTrue(mock.registerCalled, "register() 應已被調用")
        try assertTrue(manager.isEnabled, "勾選後 isEnabled 應為 true")
    }

    // MARK: - setEnabled(false) — disable

    // Calls unregister when disabled
    registerTest("test_setEnabled_false_調用unregister") {
        let mock = MockLoginItemService()
        mock.mockIsRegistered = true
        let manager = LoginItemManager(service: mock)
        manager.setEnabled(false)
        try assertTrue(mock.unregisterCalled, "unregister() 應已被調用")
        try assertFalse(manager.isEnabled, "取消勾選後 isEnabled 應為 false")
    }

    // MARK: - Failure handling

    // isEnabled stays unchanged when register throws
    registerTest("test_register失敗時_isEnabled保持false") {
        let mock = MockLoginItemService()
        mock.shouldThrowOnRegister = TestFailure(reason: "mock register error")
        let manager = LoginItemManager(service: mock)
        manager.setEnabled(true)
        try assertFalse(manager.isEnabled, "register 失敗後 isEnabled 應保持 false")
    }

    // isEnabled stays unchanged when unregister throws
    registerTest("test_unregister失敗時_isEnabled保持true") {
        let mock = MockLoginItemService()
        mock.mockIsRegistered = true
        mock.shouldThrowOnUnregister = TestFailure(reason: "mock unregister error")
        let manager = LoginItemManager(service: mock)
        manager.setEnabled(false)
        try assertTrue(manager.isEnabled, "unregister 失敗後 isEnabled 應保持 true")
    }
}
