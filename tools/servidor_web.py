"""Servidor local para la app web.

Manda las cabeceras que aislan el origen (COOP/COEP). Sin ellas, el navegador
no habilita SharedArrayBuffer y el almacenamiento de la base de datos falla.
"""
from functools import partial
from http.server import SimpleHTTPRequestHandler, ThreadingHTTPServer

class Handler(SimpleHTTPRequestHandler):
    def end_headers(self):
        self.send_header('Cross-Origin-Opener-Policy', 'same-origin')
        self.send_header('Cross-Origin-Embedder-Policy', 'require-corp')
        self.send_header('Cross-Origin-Resource-Policy', 'cross-origin')
        super().end_headers()

ThreadingHTTPServer(
    ('0.0.0.0', 8099),
    partial(Handler, directory='build/web'),
).serve_forever()
