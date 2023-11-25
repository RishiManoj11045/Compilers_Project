#include <bits/stdc++.h>
#include <initializer_list>
#include <optional>

#include <queue>
#include <stack>

using namespace::std;

template <typename T>
struct node
{
    T val;
    node<T>* left;
    node<T>* right;

    node(T value) : val(value), left(nullptr), right(nullptr) {}

    node(T value, node<T>* left, node<T>* right) : val(value), left(left), right(right) {}
};

template <typename T>
using Node = node<T>*;

template <typename T>
struct btree;

template <typename T>
using BTree = btree<T>*;


template <typename T>
struct btree
{
    Node<T> root;

    btree(initializer_list<T> values) {
        root = nullptr;
        for (const auto& value : values) {
            if(value==NULL){
                Node<T> n = NULL;
                insert(n);
                continue;
            }
            Node<T> n = new node<T> (value);
            insert(n);
        }
    }

    Node<T> getRoot() const
    {
        return root;
    }


/*
    bfs
    dfs
    inorder
    preorder
    postorder
    mergeBTree
    delete
    insert
    search
*/  
    void bfs()
    {
        if (root == nullptr)
            return;

        std::queue<Node<T>> q;
        q.push(root);

        while (!q.empty())
        {
            Node<T> current = q.front();
            q.pop();

            std::cout << current->val << " ";

            if (current->left != nullptr)
                q.push(current->left);

            if (current->right != nullptr)
                q.push(current->right);
        }
        std::cout << std::endl;
    }

    void dfs()
    {
        std::stack<Node<T>> s;
        Node<T> current = root;

        while (current != nullptr || !s.empty())
        {
            while (current != nullptr)
            {
                s.push(current);
                current = current->left;
            }

            current = s.top();
            s.pop();

            std::cout << current->val << " ";

            current = current->right;
        }
        std::cout << std::endl;
    }

    void inorder()
    {
        std::stack<Node<T>> s;
        Node<T> current = root;

        while (current != nullptr || !s.empty())
        {
            while (current != nullptr)
            {
                s.push(current);
                current = current->left;
            }

            current = s.top();
            s.pop();

            std::cout << current->val << " ";

            current = current->right;
        }
        std::cout << std::endl;
    }

    void preorder() const
    {
        std::stack<Node<T>> s;
        Node<T> current = root;
        s.push(current);

        while (!s.empty())
        {
            current = s.top();
            s.pop();

            std::cout << current->val << " ";

            if (current->right != nullptr)
                s.push(current->right);

            if (current->left != nullptr)
                s.push(current->left);
        }
        std::cout << std::endl;
    }

    void postorder() const
    {
        if (root == nullptr)
            return;

        std::stack<Node<T>> s1, s2;
        s1.push(root);

        while (!s1.empty())
        {
            Node<T> current = s1.top();
            s1.pop();
            s2.push(current);

            if (current->left != nullptr)
                s1.push(current->left);

            if (current->right != nullptr)
                s1.push(current->right);
        }

        while (!s2.empty())
        {
            Node<T> current = s2.top();
            s2.pop();
            std::cout << current->val << " ";
        }
        std::cout << std::endl;
    }

    // Insert a value into the binary tree
bool insert(Node<T> newNode)
    {
        if (root == nullptr)
        {
            root = newNode;
            return true;
        }

        std::queue<Node<T>> nodes;
        nodes.push(root);

        while (!nodes.empty())
        {
            Node<T> current = nodes.front();
            nodes.pop();

            if (current->left == nullptr)
            {
                current->left = newNode;
                return true;
            }
            else if (current->right == nullptr)
            {
                current->right = newNode;
                return true;
            }
            else
            {
                nodes.push(current->left);
                nodes.push(current->right);
            }
        }

        return false;
    }/*
In this modified version, a queue is used to perform level-order traversal (BFS) of the binary tree. 
The first empty left or right child encountered is where the new node is inserted. 
This avoids recursion and iteratively finds the first available position for insertion.
*/

// Search for a value in the binary tree
Node<T> search(Node<T> target)
    {
        if (root == nullptr)
        {
            return nullptr;
        }

        T value = target->val;

        std::queue<Node<T>> nodes;
        nodes.push(root);

        while (!nodes.empty())
        {
            Node<T> current = nodes.front();
            nodes.pop();

            if (current->val == value)
            {
                return current;
            }

            if (current->left != nullptr)
            {
                nodes.push(current->left);
            }

            if (current->right != nullptr)
            {
                nodes.push(current->right);
            }
        }

        // If the value is not found, return nullptr
        return nullptr;
    }

 Node<T> deleteN(Node<T> target)
    {
        if (root == nullptr)
        {
            return nullptr;
        }

        T value = target->val;

        std::queue<Node<T>> nodes;
        nodes.push(root);

        Node<T> targetNode = nullptr;
        Node<T> deepestNode = nullptr;

        while (!nodes.empty())
        {
            Node<T> current = nodes.front();
            nodes.pop();

            if (current->val == value)
            {
                targetNode = current;
            }

            deepestNode = current;

            if (current->left != nullptr)
            {
                nodes.push(current->left);
            }

            if (current->right != nullptr)
            {
                nodes.push(current->right);
            }
        }

        if (targetNode != nullptr)
        {
            T temp = deepestNode->val;
            deleteDeepest(root, deepestNode);
            targetNode->val = temp;
            return targetNode;  // Return the deleted node
        }

        return nullptr;  // Return nullptr if the target node was not found
    }

    void deleteDeepest(Node<T> root, Node<T> deepest)
    {
        std::queue<Node<T>> nodes;
        nodes.push(root);

        while (!nodes.empty())
        {
            Node<T> current = nodes.front();
            nodes.pop();

            if (current->right != nullptr)
            {
                if (current->right == deepest)
                {
                    delete deepest;
                    current->right = nullptr;
                    return;
                }
                else
                {
                    nodes.push(current->right);
                }
            }

            if (current->left != nullptr)
            {
                if (current->left == deepest)
                {
                    delete deepest;
                    current->left = nullptr;
                    return;
                }
                else
                {
                    nodes.push(current->left);
                }
            }
        }
    }

BTree<T> mergeBTree(BTree<T> root1, BTree<T> root2)
{
    if (root1 == nullptr)
        return root2;
    if (root2 == nullptr)
        return root1;

    queue<pair<Node<T>,Node<T>>> nodes;
    nodes.push({root1->root, root2->root});

    while (!nodes.empty())
    {
        auto currentPair = nodes.front();
        nodes.pop();

        Node<T> node1 = currentPair.first;
        Node<T> node2 = currentPair.second;

        // Merge the values
        node1->val += node2->val;

        if (node1->left != nullptr && node2->left != nullptr)
        {
            nodes.push({node1->left, node2->left});
        }
        else if (node2->left != nullptr)
        {
            node1->left = node2->left;
        }

        if (node1->right != nullptr && node2->right != nullptr)
        {
            nodes.push({node1->right, node2->right});
        }
        else if (node2->right != nullptr)
        {
            node1->right = node2->right;
        }
    }

    return root1;
}

};

template <typename T>
using BTree = btree<T>*;


template <typename T>
struct bstree;

template <typename T>
using BSTree = bstree<T> *;


template <typename T>
struct bstree
{
    Node<T> root;

    // Constructor to create a node with a given value
    bstree(T val){
        root=new node<T>(val);
        root->left=nullptr; 
        root->right=nullptr;
    }

    // Initializer list constructor to build a binary search tree
   bstree(initializer_list<T> values) : root(nullptr) {
        for (const T &val : values) {
            Node<T> n=new node<T>(val);
            insert(n);
        }
    }

    bool insert(Node<T> newNode) {
        if(root==NULL){
            root=newNode;
        }
        return insert1(root, newNode);
    }

    // Insert a node into the binary search tree
    bool insert1(Node<T> root1, Node<T> newNode)
    {
        if (newNode == nullptr)
        {
            return false;
        }

        if (newNode->val < root1->val)
        {
            if (root1->left == nullptr)
            {
                root1->left = newNode;
                return true;
            }
            else
            {
                return insert1(root1->left, newNode);
            }
        }
        else if (newNode->val > root1->val)
        {
            if (root1->right == nullptr)
            {
                root1->right = newNode;
                return true;
            }
            else
            {
                return insert1(root1->right, newNode);
            }
        }
        return false; // Duplicate values are not allowed
    }
    Node<T> search(Node<T> searchNode){
        return search1(root,searchNode);
    }

    // Search for a node in the binary search tree
    Node<T> search1(Node<T> root1,Node<T> searchNode)
    {
        T value = searchNode->val;

        if (value == root1->val)
        {
            return root1;
        }
        else if (value < root1->val && root1->left != nullptr)
        {
            return search1(root1->left, searchNode);
        }
        else if (value > root1->val && root1->right != nullptr)
        {
            return search1(root1->right, searchNode);
        }

        return nullptr;
    }

// Delete a value from the binary search tree
Node<T> deleteNode(Node<T> root1, T k)
{
    // Base case
    if (root1 == nullptr)
        return root1;

    // Recursive calls for ancestors of the node to be deleted
    if (root1->val > k) {
        root1->left = deleteNode(root1->left, k);
        return root1;
    }
    else if (root1->val < k) {
        root1->right = deleteNode(root1->right, k);
        return root1;
    }

    // We reach here when root1->val == k.

    // If one of the children is empty
    if (root1->left == nullptr) {
        Node<T> temp = root1->right;
        delete root1;
        return temp;
    }
    else if (root1->right == nullptr) {
        Node<T> temp = root1->left;
        delete root1;
        return temp;
    }

    // If both children exist
    else {
        Node<T> succParent = root1;

        // Find successor
        Node<T> succ = root1->right;
        while (succ->left != nullptr) {
            succParent = succ;
            succ = succ->left;
        }

        // Delete successor and copy its data to root1
        T temp = succ->val;
        root1->right = deleteNode(root1->right, temp);  // Recursively delete the successor from the right subtree
        root1->val = temp;

        return root1;
    }
}

// Example usage in the `deleteN` function
Node<T> deleteN(Node<T> del) {
    return deleteNode(root, del->val);
}


    // Find the node with the minimum value in a binary search tree
    Node<T> minValueNode(Node<T> node)
    {
        Node<T> current = node;

        while (current->left != nullptr)
            current = current->left;

        return current;
    }



    void bfs()
    {
        if (root == nullptr)
            return;

        std::queue<Node<T>> q;
        q.push(root);

        while (!q.empty())
        {
            Node<T> current = q.front();
            q.pop();

            std::cout << current->val << " ";

            if (current->left != nullptr)
                q.push(current->left);

            if (current->right != nullptr)
                q.push(current->right);
        }
        std::cout << std::endl;
    }

    void dfs()
    {
        stack<Node<T>> s;
        Node<T> current = root;

        while (current != nullptr || !s.empty())
        {
            while (current != nullptr)
            {
                s.push(current);
                current = current->left;
            }

            current = s.top();
            s.pop();

            std::cout << current->val << " ";

            current = current->right;
        }
        std::cout << std::endl;
    }

    void inorder()
    {
        std::stack<Node<T>> s;
        Node<T> current = root;

        while (current != nullptr || !s.empty())
        {
            while (current != nullptr)
            {
                s.push(current);
                current = current->left;
            }

            current = s.top();
            s.pop();

            std::cout << current->val << " ";

            current = current->right;
        }
        std::cout << std::endl;
    }

    void preorder() const
    {
        std::stack<Node<T>> s;
        Node<T> current = root;
        s.push(current);

        while (!s.empty())
        {
            current = s.top();
            s.pop();

            std::cout << current->val << " ";

            if (current->right != nullptr)
                s.push(current->right);

            if (current->left != nullptr)
                s.push(current->left);
        }
        std::cout << std::endl;
    }

    void postorder() const
    {
        if (root == nullptr)
            return;

        std::stack<Node<T>> s1, s2;
        s1.push(root);

        while (!s1.empty())
        {
            Node<T> current = s1.top();
            s1.pop();
            s2.push(current);

            if (current->left != nullptr)
                s1.push(current->left);

            if (current->right != nullptr)
                s1.push(current->right);
        }

        while (!s2.empty())
        {
            Node<T> current = s2.top();
            s2.pop();
            std::cout << current->val << " ";
        }
        std::cout << std::endl;
    }

BSTree<T> mergeBSTree(BSTree<T> root1, BSTree<T> root2)
{
    if (root1->root == nullptr)
        return root2;
    if (root2->root == nullptr)
        return root1;

    std::stack<std::pair<Node<T>, Node<T>>> stack;
    stack.push(std::make_pair(root1->root, root2->root));

    while (!stack.empty())
    {
        auto currentPair = stack.top();
        stack.pop();

        Node<T> current1 = currentPair.first;
        Node<T> current2 = currentPair.second;

        if (current1 == nullptr || current2 == nullptr)
            continue;

        // Merge the values
        current1->val += current2->val;

        // Process left subtrees
        if (current1->left == nullptr)
        {
            current1->left = current2->left;
        }
        else
        {
            stack.push(std::make_pair(current1->left, current2->left));
        }

        // Process right subtrees
        if (current1->right == nullptr)
        {
            current1->right = current2->right;
        }
        else
        {
            stack.push(std::make_pair(current1->right, current2->right));
        }
    }

    return root1;
}
};

template <typename T>
using BSTree = bstree<T> *;
