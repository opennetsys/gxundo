package main

import (
	"fmt"
	cid "/"
	"log"
)

func main() {
	// Create a cid manually by specifying the 'prefix' parameters
	pref := cid.Prefix{
		Version:  1,
		Codec:    cid.Raw,
		MhLength: -1, // default length
	}

	// And then feed it some data
	c, err := pref.Sum([]byte("Hello World!"))
	if err != nil {
		log.Fatal(err)
	}

	fmt.Println("Created CID: ", c)
}
