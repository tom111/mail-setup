#!/usr/bin/python

import re
import sys
import gtk
import gnomekeyring as gkey

class Keyring(object):
    def __init__(self, name, server, protocol):
        self._name = name
        self._server = server
        self._protocol = protocol
        self._keyring = gkey.get_default_keyring_sync()

    def has_credentials(self):
        try:
            attrs = {"server": self._server, "protocol": self._protocol}
            items = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)
            return len(items) > 0
        except gkey.DeniedError:
            return False

    def get_credentials(self):
        attrs = {"server": self._server, "protocol": self._protocol}
        items = gkey.find_items_sync(gkey.ITEM_NETWORK_PASSWORD, attrs)
        return (items[0].attributes["user"], items[0].secret)

    def set_credentials(self, (user, pw)):
        attrs = {
                "user": user,
                "server": self._server,
                "protocol": self._protocol,
            }
        gkey.item_create_sync(gkey.get_default_keyring_sync(),
                gkey.ITEM_NETWORK_PASSWORD, self._name, attrs, pw, True)

def get_username(server):
    keyring = Keyring("offlineimap", server, "imap")
    (username, password) = keyring.get_credentials()
    return username

def get_password(server):
    keyring = Keyring("offlineimap", server, "imap")
    (username, password) = keyring.get_credentials()
    return password

def oimaptransfolder_acc1(foldername):
    if(foldername == "INBOX"):
        retval = "acc1"
    else:
        retval = "acc1." + foldername
    retval = re.sub("/", ".", retval)
    return retval
    
def localtransfolder_acc1(foldername):
    if(foldername == "acc1"):
        retval = "INBOX"
    else:
        # remove leading 'acc1.'
        retval = re.sub("acc1\.", "", foldername)
    retval = re.sub("\.", "/", retval)
    return retval
