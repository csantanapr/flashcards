func main(args: [String:Any]) -> [String:Any] {
    var args = args
    guard let method = args["__ow_method"] as? String,
          let path = args["__ow_path"] as? String else {
        return ["statusCode": 500]
    }

    // simple routing - map verb to action name for resource and collection
    var verbs: [String:String] = [:]
    if (path.characters.count > 1) {
        // action on a single resource
        verbs = ["get": "getCard", "put": "updateCard", "delete": "deleteCard"]

        // set card id into args for the call to the action that will do the work
        args["card_id"] = String(path.characters.dropFirst())
    } else {
        // actions on the collection
        verbs = ["get": "getCollection", "post": "addCard"]
    }

    guard let action = verbs[method.lowercased()] else {
        return ["statusCode": 405]
    }

    // invoke action
    let actionName = getFullActionName(for:action)
    print("Invoking action '\(actionName)'")
    let result = Whisk.invoke(actionNamed: actionName, withParameters: args, blocking: true)

    let response = result["response"] as? [String:Any] ?? [:]
    let success = response["success"] as? Bool ?? false
    if success == true {
        return response["result"] as! [String:Any]
    }

    print("Error invoking action")
    dump(response)
    return jsonResponse(["error": "Internal Server Error"], code: 500)
}