"""The gateway, split up.

The gateway was one file of nearly four thousand lines holding the Flask app,
its wiring, sixty-odd HTTP routes and the whole AMF0 protocol. It is being
taken apart into this package one concern at a time, and this is where the
parts that have already moved live:

- ``shared``: the pieces the Flask surface and the AMF core both need.
- ``routes``: the HTTP surface, one blueprint per concern.
- ``assets``: the files the client downloads -- the SWF, the settings and the
  artwork.

What is left in ``empires-server.py`` is the AMF protocol and the wiring that
puts it together.

The seams are blueprints rather than plain functions so that each piece can be
registered on the app in one line and read on its own.
"""
