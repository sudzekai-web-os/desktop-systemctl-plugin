.pragma library

function state(value) {
    const labels = { active: "Работает", inactive: "Остановлена", failed: "Ошибка",
        activating: "Запускается", deactivating: "Останавливается", loaded: "Загружена",
        "not-found": "Не найдена", enabled: "Включён", disabled: "Выключен", static: "Статический",
        masked: "Заблокирована" }
    return labels[value] || value || "—"
}
