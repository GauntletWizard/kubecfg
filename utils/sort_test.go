package utils

import (
	"reflect"
	"sort"
	"testing"

	"k8s.io/client-go/pkg/runtime"
)

var _ sort.Interface = DependencyOrder{}

func TestDepSort(t *testing.T) {
	newObj := func(apiVersion, kind string) *runtime.Unstructured {
		return &runtime.Unstructured{
			Object: map[string]interface{}{
				"apiVersion": apiVersion,
				"kind":       kind,
			},
		}
	}

	objs := []*runtime.Unstructured{
		newObj("extensions/v1beta1", "Deployment"),
		newObj("v1", "ConfigMap"),
		newObj("v1", "Namespace"),
		newObj("v1", "Service"),
	}

	sort.Sort(DependencyOrder(objs))

	if objs[0].GetKind() != "Namespace" {
		t.Error("Namespace should be sorted first")
	}
	if objs[3].GetKind() != "Deployment" {
		t.Error("Deployment should be sorted after other objects")
	}
}

func TestAlphaSort(t *testing.T) {
	newObj := func(ns, name, kind string) *runtime.Unstructured {
		o := runtime.Unstructured{}
		o.SetNamespace(ns)
		o.SetName(name)
		o.SetKind(kind)
		return &o
	}

	objs := []*runtime.Unstructured{
		newObj("default", "mysvc", "Deployment"),
		newObj("", "default", "StorageClass"),
		newObj("", "default", "ClusterRole"),
		newObj("default", "mydeploy", "Deployment"),
		newObj("default", "mysvc", "Secret"),
	}

	expected := []*runtime.Unstructured{
		objs[2],
		objs[1],
		objs[3],
		objs[0],
		objs[4],
	}

	sort.Sort(AlphabeticalOrder(objs))

	if !reflect.DeepEqual(objs, expected) {
		t.Errorf("actual != expected: %v != %v", objs, expected)
	}
}
