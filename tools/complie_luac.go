package main

import (
	"bytes"
	"fmt"
	"io"
	"os"
	"os/exec"
	"path/filepath"
	"time"
)

const (
	IsDirectory = iota
	IsRegular
	IsSymlink
)

type sysFile struct {
	fType  int
	fName  string
	fLink  string
	fSize  int64
	fMtime time.Time
	fPerm  os.FileMode
	fN     string
}

type F struct {
	files []*sysFile
}

func (self *F) visit(path string, f os.FileInfo, err error) error {
	if f == nil {
		return err
	}
	var tp int
	if f.IsDir() {
		tp = IsDirectory
		return nil
	} else if (f.Mode() & os.ModeSymlink) > 0 {
		tp = IsSymlink
	} else {
		tp = IsRegular
	}
	inoFile := &sysFile{
		fName:  path,
		fType:  tp,
		fPerm:  f.Mode(),
		fMtime: f.ModTime(),
		fSize:  f.Size(),
		fN:     f.Name(),
	}
	self.files = append(self.files, inoFile)
	return nil
}

func CopyFile(src, des string) (w int64, err error) {
	srcFile, err := os.Open(src)
	if err != nil {
		fmt.Println(err)
	}
	defer srcFile.Close()

	desFile, err := os.Create(des)
	if err != nil {
		fmt.Println(err)
	}
	defer desFile.Close()

	return io.Copy(desFile, srcFile)
}

func main() {

	root, _ := os.Getwd()
	self := F{
		files: make([]*sysFile, 0),
	}
	err := filepath.Walk(root+"assets/src", func(path string, f os.FileInfo, err error) error {
		return self.visit(path, f, err)
	})

	if err != nil {
		fmt.Printf("filepath.Walk() returned %v\n", err)
	}

	var (
		cmd *exec.Cmd
		out bytes.Buffer
	)

	for _, v := range self.files {

		fmt.Println(v.fName)

		w, err1 := CopyFile(v.fName, v.fN)
		if err1 != nil {
			fmt.Println(err1.Error())
		}
		fmt.Println(w)

		cmd = exec.Command("luac.exe", "-o", v.fN+"c", v.fN)
		//cmd.Env = os.Environ()
		cmd.Stdout = &out
		if err := cmd.Run(); err != nil {
			fmt.Println(err) //exit status -1
			return
		}
		fmt.Println(out.String())

		w, err1 = CopyFile(v.fN+"c", v.fName)

		//os.Remove(v.fName)
		os.Remove(v.fN + "c")
		os.Remove(v.fN)
	}
}
