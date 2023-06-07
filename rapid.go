package main

import (
    "flag"
    "io"
    "net/http"
    "os"
)

func main() {
    domainPtr := flag.String("u", "", "domain name to fetch")
    outputPtr := flag.String("o", "", "output file name")
    flag.Parse()

    if *domainPtr == "" {
        flag.PrintDefaults()
        os.Exit(1)
    }

    url := "https://domains-records.p.rapidapi.com/stream/subdomains/" + *domainPtr + "?weeks=8&limit=2000"

    req, _ := http.NewRequest("GET", url, nil)

    req.Header.Add("X-RapidAPI-Key", "Enter your api-key here")
    req.Header.Add("X-RapidAPI-Host", "domains-records.p.rapidapi.com")

    res, _ := http.DefaultClient.Do(req)

    defer res.Body.Close()

    if *outputPtr == "" {
        _, err := io.Copy(os.Stdout, res.Body)
        if err != nil {
            panic(err)
        }
    } else {
        file, err := os.Create(*outputPtr)
        if err != nil {
            panic(err)
        }
        defer file.Close()

        _, err = io.Copy(file, res.Body)
        if err != nil {
            panic(err)
        }
    }
}
