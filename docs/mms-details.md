## <a id=mms-details></a> More MSS Details

The `hzn mms ...` command provides additional tooling for working with the MMS. Get  help for this command with:

```bash
hzn mms --help
```

A good place to start is with the `hzn mms object new` command, which will emit an MMS object metadata template. You can take this template, fill in the fields that are relevant to your use case, and remove all of the "comments" wrapped in `/* ... */`. Then you can pass it to the `hzn mms object publish -m <my-metadata-file` (as your `<my-metadata-file>`).

To publish an object with the MMS, you can use the scripts you used above, or the `hzn mms object publish ...` command. For the latter you need to provide `-t <my-type>` and `-i <my-id>` (passing your own type, `<my-type>`, and ID, `<my-id>`). This command also takes a `-p <my-pattern>` flag that you can use to tell the MMS to deliver this object only to Edge Nodes that are registered with Deployment Pattern `<my-pattern>.



The `hzn mms object list -t <my-type>` can be used to list all the MMS objects of type, `<my-type>`.

To delete a specific object, of type `<my-type>` with ID `<my-id>` you can use, `hzn mms object delete -t <my-type> -i <my-id>`.

To view the current MMS status, use, `hzn mms status`.
