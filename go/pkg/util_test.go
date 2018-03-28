package pkg

import (
	"fmt"
	"io/ioutil"
	"os"
	"testing"
)

var (
	testdata = "testdata"
)

func TestCreateFile(t *testing.T) {

	var testFile = testdata + "/test"
	err := CreateFile(testFile)
	if err != nil {
		t.Fatalf("E! CreateFile() failed: %v", err)
	}
	_, err = os.Stat(testFile)
	if err != nil {
		t.Fatalf("E! can't get file status: %v", err)
	}

	defer func() {
		// cleanup
		os.Remove(testFile)
	}()
}

func TestCreateFileWithContent(t *testing.T) {

	var testFile = testdata + "/test"
	var testContent = "asdf"
	err := CreateFileWithContent(testFile, testContent)
	if err != nil {
		t.Fatalf("E! CreateFileWithContent() failed: %v", err)
	}

	content, err := ioutil.ReadFile(testFile)
	if err != nil {
		t.Fatalf("E! read file failed: %v", err)
	}

	if testContent != fmt.Sprintf("%s", content) {
		t.Fatalf("E! file content don't match")
	}

	defer func() {
		// cleanup
		os.Remove(testFile)
	}()
}

func TestCreateDir(t *testing.T) {

	var testDir = testdata + "/test"
	err := CreateDir(testDir)
	if err != nil {
		t.Fatalf("E! CreateDir() failed: %v", err)
	}

	dir, err := os.Stat(testDir)
	if err != nil {
		t.Fatalf("E! can't get dir status: %v", err)
	}

	if !dir.IsDir() {
		t.Fatalf("E! %s is not a dir", testDir)
	}

	defer func() {
		// cleanup
		os.Remove(testDir)
	}()
}

func TestCreateSoftLink(t *testing.T) {

	var testFile = testdata + "/test"
	var testLink = testdata + "/test_link"

	CreateFile(testFile)
	err := CreateSoftLink(testFile, testLink)
	if err != nil {
		t.Fatalf("E! CreateSoftLink() failed: %v", err)
	}
	link, err := os.Lstat(testLink)
	if err != nil {
		t.Fatalf("E! can't get link status: %v", err)
	}
	if link.Mode()&os.ModeSymlink == 0 {
		t.Fatalf("E! %s is not a soft link", link.Name())
	}

	defer func() {
		// cleanup
		os.Remove(testFile)
		os.Remove(testLink)
	}()
}

func TestIsDir(t *testing.T) {

	b, err := IsDir(testdata)
	if err != nil {
		t.Fatalf("E! IsDir failed: %v", err)
	}
	if !b {
		t.Fatalf("E! %s is dir", testdata)
	}
}
