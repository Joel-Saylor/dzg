# Script to trigger julia AOT compilation
from time import sleep

import requests

URL = "http://127.0.0.1:8000"


def upload_file(file) -> str:
    files = {"inputfile": open(file, "rb")}
    payload = {"name": "Steve", "email": "steve.s.paul22@gmail.com"}
    response = requests.post(URL + "/api/upload", data=payload, files=files)
    return response.json()["data"]


def get_input_viz(id):
    notSuccess = True
    while notSuccess:
        response = requests.get(URL + "/api/report/input-viz/" + id)
        if response.json()["message"] == "Success":
            notSuccess = False
        else:
            print("InputViz: " + response.json()["message"])
        sleep(10)


def post_source_analysis(id, payload={"override_rank": False, "custom_rank": 3}):
    headers = {"content-type": "application/json"}

    response = requests.post(
        URL + "/api/report/source-analysis/" + id, json=payload, headers=headers
    )

    if response.json()["message"] != "Success":
        RuntimeError(response.json()["message"])


def get_source_analysis(id):
    notSuccess = True
    while notSuccess:
        response = requests.get(URL + "/api/report/source-analysis/" + id)
        if response.json()["message"] == "Success":
            notSuccess = False
        else:
            print("SourceAnalysis: " + response.json()["message"])
        sleep(10)


if __name__ == "__main__":
    try:
        id = upload_file("Saylor-12sinks-10meas-dzg.xlsx")
        get_input_viz(id)
        post_source_analysis(id)
        get_source_analysis(id)
        post_source_analysis(id, payload={"override_rank": True, "custom_rank": 3})
        get_source_analysis(id)
    except Exception as e:
        print(e)
        print("Error in running example")
