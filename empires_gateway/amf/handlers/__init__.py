"""The game's rules, by domain.

Each module holds the handlers for one part of the game, and the dispatch
table in ``empires_gateway.amf.dispatch`` is what wires them to the names the
client calls.

A handler answers with the payload the client expects, and nothing else: it
does not know about AMF, about the envelope, or about the batch. That is what
the protocol module is for.
"""
