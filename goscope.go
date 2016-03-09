package main

import (
	"launchpad.net/go-unityscopes/v2"
	"log"
)

const searchCategoryTemplate = `{
  "schema-version": 1,
  "template": {
    "category-layout": "grid",
    "card-size": "small"
  },
  "components": {
    "title": "title",
    "art":  "art",
    "subtitle": "username"
  }
}`

// SCOPE ***********************************************************************

var scope_interface scopes.Scope

type MyScope struct {
	base *scopes.ScopeBase
}

type actionInfo struct {
        Id    string `json:"id"`
        Label string `json:"label"`
        Icon  string `json:"icon,omitempty"`
        Uri   string `json:"uri,omitempty"`
}

func (s *MyScope) Preview(result *scopes.Result, metadata *scopes.ActionMetadata, reply *scopes.PreviewReply, cancelled <-chan bool) error {
	layout1col := scopes.NewColumnLayout(1)
	layout2col := scopes.NewColumnLayout(2)
	layout3col := scopes.NewColumnLayout(3)

	// Single column layout
	layout1col.AddColumn("image", "header", "summary", "rating", "actions")

	// Two column layout
	layout2col.AddColumn("image")
	layout2col.AddColumn("header", "summary", "rating", "actions")

	// Three cokumn layout
	layout3col.AddColumn("image")
	layout3col.AddColumn("header", "summary", "rating", "actions")
	layout3col.AddColumn()

	// Register the layouts we just created
	reply.RegisterLayout(layout1col, layout2col, layout3col)

	header := scopes.NewPreviewWidget("header", "header")

	// It has title and a subtitle properties
	header.AddAttributeMapping("title", "title")
	header.AddAttributeMapping("subtitle", "subtitle")

	// Define the image section
	image := scopes.NewPreviewWidget("image", "image")
	// It has a single source property, mapped to the result's art property
	image.AddAttributeMapping("source", "art")

	// Define the summary section
	description := scopes.NewPreviewWidget("summary", "text")
	// It has a text property, mapped to the result's description property
	description.AddAttributeMapping("text", "description")

	actions := scopes.NewPreviewWidget("actions", "actions")
	actions.AddAttributeValue("actions", []actionInfo{
		actionInfo{Id: "my_action", Label: "Close"},
		actionInfo{Id: "my_action2", Label: "Refresh"},
	})

	rating := scopes.NewPreviewWidget("rating", "rating-input")
	rating.AddAttributeValue("visible", "both")
	rating.AddAttributeValue("required", "rating")

	var scope_data string
	metadata.ScopeData(scope_data)
	if len(scope_data) > 0 {
		extra := scopes.NewPreviewWidget("extra", "text")
		extra.AddAttributeValue("text", "test Text")
		reply.PushWidgets(header, image, description, actions, rating, extra)
	} else {
		reply.PushWidgets(header, image, description, rating, actions)
	}

	return nil
}

func (s *MyScope) Search(query *scopes.CannedQuery, metadata *scopes.SearchMetadata, reply *scopes.SearchReply, cancelled <-chan bool) error {
	root_department := s.CreateDepartments(query, metadata, reply)
	reply.RegisterDepartments(root_department)

	// test incompatible features in RTM version of libunity-scopes
	filter1 := scopes.NewOptionSelectorFilter("f1", "Options", false)
	var filterState scopes.FilterState
	// for RTM version of libunity-scopes we should see a log message
	reply.PushFilters([]scopes.Filter{filter1}, filterState)
	
	return s.AddQueryResults(reply, query.QueryString())
}

func (s *MyScope) SetScopeBase(base *scopes.ScopeBase) {
	s.base = base
}

// RESULTS *********************************************************************

func (s *MyScope) AddQueryResults(reply *scopes.SearchReply, query string) error {
	cat := reply.RegisterCategory("category", "Category", "", searchCategoryTemplate)

	result := scopes.NewCategorisedResult(cat)
	result.SetURI("http://localhost/" + query)
	result.SetDndURI("http://localhost_dnduri" + query)
	result.SetTitle("TEST----" + query)
	result.SetArt("http://bbs.unpcn.com/attachment.aspx?attachmentid=4262277")
	result.Set("test_value_bool", true)
	result.Set("test_value_string", "test_value"+query)
	result.Set("test_value_int", 1999)
	result.Set("test_value_float", 1.999)
	if err := reply.Push(result); err != nil {
		return err
	}

	result.SetURI("http://localhost2/" + query)
	result.SetDndURI("http://localhost_dnduri2" + query)
	result.SetTitle("TEST2")
	result.SetArt("http://bbs.unpcn.com/attachment.aspx?attachmentid=4235976")
	result.Set("test_value_bool", false)
	result.Set("test_value_string", "test_value2"+query)
	result.Set("test_value_int", 2000)
	result.Set("test_value_float", 2.100)

	// add a variant map value
	m := make(map[string]interface{})
	m["value1"] = 1
	m["value2"] = "string_value"
	result.Set("test_value_map", m)

	// add a variant array value
	l := make([]interface{}, 0)
	l = append(l, 1999)
	l = append(l, "string_value")
	result.Set("test_value_array", l)
	// This causes the dash to invoke our Activate() method when
	// the user attempts to activate the result, rather than
	// handling it directly.
	result.SetInterceptActivation()
	if err := reply.Push(result); err != nil {
		return err
	}

	return nil
}

// DEPARTMENTS *****************************************************************

func SearchDepartment(root *scopes.Department, id string) *scopes.Department {
	sub_depts := root.Subdepartments()
	for _, element := range sub_depts {
		if element.Id() == id {
			return element
		}
	}
	return nil
}

func (s *MyScope) GetRockSubdepartments(query *scopes.CannedQuery,
	metadata *scopes.SearchMetadata,
	reply *scopes.SearchReply) *scopes.Department {
	active_dep, err := scopes.NewDepartment("Rock", query, "Rock Music")
	if err == nil {
		active_dep.SetAlternateLabel("Rock Music Alt")
		department, _ := scopes.NewDepartment("60s", query, "Rock from the 60s")
		active_dep.AddSubdepartment(department)

		department2, _ := scopes.NewDepartment("70s", query, "Rock from the 70s")
		active_dep.AddSubdepartment(department2)
	}

	return active_dep
}

func (s *MyScope) GetSoulSubdepartments(query *scopes.CannedQuery,
	metadata *scopes.SearchMetadata,
	reply *scopes.SearchReply) *scopes.Department {
	active_dep, err := scopes.NewDepartment("Soul", query, "Soul Music")
	if err == nil {
		active_dep.SetAlternateLabel("Soul Music Alt")
		department, _ := scopes.NewDepartment("Motown", query, "Motown Soul")
		active_dep.AddSubdepartment(department)

		department2, _ := scopes.NewDepartment("New Soul", query, "New Soul")
		active_dep.AddSubdepartment(department2)
	}

	return active_dep
}

func (s *MyScope) CreateDepartments(query *scopes.CannedQuery,
	metadata *scopes.SearchMetadata,
	reply *scopes.SearchReply) *scopes.Department {
	department, _ := scopes.NewDepartment("", query, "Browse Music")
	department.SetAlternateLabel("Browse Music Alt")

	rock_dept := s.GetRockSubdepartments(query, metadata, reply)
	if rock_dept != nil {
		department.AddSubdepartment(rock_dept)
	}

	soul_dept := s.GetSoulSubdepartments(query, metadata, reply)
	if soul_dept != nil {
		department.AddSubdepartment(soul_dept)
	}

	return department
}

// ACTIONS *********************************************************************

func (sc *MyScope) PerformAction(result *scopes.Result, metadata *scopes.ActionMetadata, widgetId, actionId string) (*scopes.ActivationResponse, error) {
	log.Printf("Perform action for widget=%s, action=%s\n", widgetId, actionId)
	
	// var scope_data interface{}
	var scope_data map[string]interface{}
	metadata.ScopeData(&scope_data)
	
	log.Println("rating: ", scope_data["rating"])
	log.Println("review: ", scope_data["review"])

	for key, value := range scope_data {
		log.Println("key: ", key)
		log.Println("value: ", value)		
	}
	
	if widgetId == "actions" && actionId == "my_action" {
		resp := scopes.NewActivationResponse(scopes.ActivationHideDash)
		resp.SetScopeData([]string{"hello", "world"})
		return resp, nil
	} 

	return scopes.NewActivationResponse(scopes.ActivationShowPreview), nil
}

// MAIN ************************************************************************

func main() {
	var sc MyScope
	scope_interface = &sc

	if err := scopes.Run(&MyScope{}); err != nil {
		log.Fatalln(err)
	}
}
