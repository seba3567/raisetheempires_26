"""The gateway, split up.

The gateway was one file of nearly four thousand lines holding the Flask app,
its wiring, sixty-odd HTTP routes and the whole AMF0 protocol. It is being
taken apart into this package one concern at a time, and this is where the
parts that have already moved live:

- ``shared``: the pieces the Flask surface and the AMF core both need.
- ``routes``: the HTTP surface, one blueprint per concern.
- ``assets``: the files the client downloads -- the SWF, the settings and the
  artwork.
- ``amf``: the protocol and the game's rules.
  - ``amf.protocol``: the rules of the wire, with no game in them.
  - ``amf.handlers``: the game's rules, one module per domain.
  - ``amf.dispatch``: the table that wires the handlers to the names the
    client calls, and the route that carries the batch.

What is left in ``empires-server.py`` is the wiring that puts it together: the
app, the extensions, the socket.io events and the entry point.

The seams are blueprints rather than plain functions so that each piece can be
registered on the app in one line and read on its own.
"""
