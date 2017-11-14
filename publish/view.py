def services(request):
    conf = os.path.join(''.join(os.path.split(os.path.realpath(__file__))[:-1]),'services.conf')
    x = service(conf)
    if request.method == "GET":
        return render_to_response('services.html',{'data':x.run()})

    elif request.method == "POST" and  request.is_ajax:
        querydict = request.POST
        data = querydict.dict()
        action = int(data['action'])
        appname = data['appname'].encode('utf-8')
        if action == 0:
            result = x.startService(appname)
        elif action == 1:
            result = x.stopService(appname)
        else:
            result = x.restartService(appname)
        return HttpResponse(json.dumps(result))
