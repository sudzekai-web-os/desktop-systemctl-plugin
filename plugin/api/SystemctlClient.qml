import linctrl

PluginRequest {
    function servicePath(name) {
        return "/systemctl/services/" + encodeURIComponent(name)
    }

    function list(target, completed) {
        const route = target ? "/systemctl/targets/" + encodeURIComponent(target) + "/services" : "/systemctl/services"
        send("GET", route, {}, completed)
    }

    function inspect(name, completed) {
        send("GET", servicePath(name), {}, completed)
    }

    function change(name, command, completed) {
        send("POST", servicePath(name) + "/" + command, {}, completed)
    }

    function readFile(name, completed) {
        send("GET", servicePath(name) + "/file", {}, completed)
    }

    function saveFile(name, content, creating, completed) {
        send(creating ? "POST" : "PUT", creating ? "/systemctl/services" : servicePath(name) + "/file",
            { name, content }, completed)
    }

    function remove(name, completed) {
        send("DELETE", servicePath(name), {}, completed)
    }

    function restartPolicy(name, enabled, completed) {
        send("PUT", servicePath(name) + "/restart-policy", { enabled }, completed)
    }

    function targets(completed) {
        send("GET", "/systemctl/targets", {}, completed)
    }

    function addTarget(name, target, completed) {
        send("POST", servicePath(name) + "/targets", { target }, completed)
    }
}
