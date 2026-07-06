local Context = {}

Context.State = {
    Tabs = {},
    ActiveTab = nil,
    UI = nil
}

function Context:Init()
    print("[Context] Initialized")
end

function Context:RegisterTab(name, data)
    self.State.Tabs[name] = data
end

function Context:SetActiveTab(name)
    self.State.ActiveTab = name

    if self.State.Tabs[name] and self.State.Tabs[name].OnOpen then
        self.State.Tabs[name].OnOpen()
    end
end

return Context
