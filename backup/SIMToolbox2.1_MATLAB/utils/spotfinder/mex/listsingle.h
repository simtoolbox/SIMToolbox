#ifndef __LISTSINGLE_H__
#define __LISTSINGLE_H__

// ---------------------------------------------------------------------------
// templated single-linked list
// ---------------------------------------------------------------------------

template <typename T>
class ListSingle {

private:
	struct item {
		T     val;
		item  *next;

		item(item *next, const T & val)
		: val(val), next(next)
		{}
	};

	item *list;  // pointer to the list
	int num;     // number of items in the list

public:

	// default constructor
	ListSingle()
	: list(NULL), num(0)
	{}
	
	~ListSingle()
	{
		DeleteAll();
	}

	// add item
	ListSingle& AddHead(const T & val)
	{
		list = (item *) new item(list, val);
		num++;
		return *this;
	}

	// delete item
	T DeleteHead()
	{
		if (!list)
			throw "LISTSINGLE: List is empty.";

		item *p = list;
		list = p->next;
		T val = p->val;		
		num--;
		delete p;
		return val;
	}
	
	// delete all items
	void DeleteAll()
	{
		item *p;
		while ( (p = list) != NULL)
		{
			list = p->next;
			//delete p->val; ???
			delete p;
			num--;
		}
	}

	// number of items in the list
	int Num()
	const
	{
		return num;
	}

	// number of items in the list
	bool IsEmpty()
	const
	{
		return (list == NULL);
	}

	// cancel copy constructor (Virius 1, p.140)
	ListSingle(const ListSingle&);
	ListSingle& operator=(const ListSingle&);
};

// ---------------------------------------------------------------------------
#endif
