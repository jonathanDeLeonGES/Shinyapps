#!/usr/bin/env python3

from __future__ import print_function

import json
from airflow import settings
from airflow.models import Connection
from sqlalchemy.orm import exc


class InitializeConnections(object):

    def __init__(self):
        self.session = settings.Session()

    def has_connection(self, conn_id):
        try:
            (
                self.session.query(Connection)
                .filter(Connection.conn_id == conn_id)
                .one()
            )
        except exc.NoResultFound:
            return False
        return True

    def delete_all_connections(self):
        self.session.query(Connection.conn_id).delete()
        self.session.commit()

    def add_connection(self, **args):
        """
        conn_id, conn_type, extra, host, login,
        password, port, schema, uri
        """
        self.session.add(Connection(**args))
        self.session.commit()


if __name__ == "__main__":

    #Initialize connections to Airflow
    ic = InitializeConnections()

    # delete all the default connections
    print("Removing example connections")
    ic.delete_all_connections()

    # add default S3 connection
    print("Adding default connection Mysql: mysql")
    ic.add_connection(conn_id="airflow_db",
                      conn_type='mysql',
                      host='db',
                      schema='covid',
                      login='covid',
                      password='covid123',
                      port=3306)

    print("Adding file path to monitor: fs_default")
    ic.add_connection(conn_id="fs_default",
                      conn_type='fs',
                      extra=json.dumps(dict(path='/home/airflow/monitor')))